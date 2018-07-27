function graph = preprocessing(A,label,X,c1,c2,c3,c4,d)

% preprocessing - find the adjacency matrix, lapalcian...for each graph
%
%   graph = preprocessing(A,label,X,c1,c2,c3,c4)
%
%   INPUT: 
%       A:      the adjacency matrix for each graph
%       label:  the node label for each graph
%       X:      the layout for each graph (optional, only for illustration)
%       c1:     (parameter) set the consistency penalty
%       c2:     (parameter) penalty to preserve the graph distance
%       c3:     (parameter) penalty to preserve the distance of directly
%       connected nodes
%       c4:     (parameter) for the nodes with the same label to get closer
%        d:     (optional) graph distance to be preserved
%   OUTPUT: 
%       graph:  contains all relevant information for each graph
%
%   This function is used to construct the variable graph, which contains
%   the adjacency, laplacian, graph distance matrix for each graph; and for
%   each pair of graph, contains the correspondences matrix constructed
%   from the label, and the penalties to preserve the node consistency and
%   the graph distances

n = length(A);                  % number of graphs
m = cellfun(@(x) size(x,1),A);  % the number of nodes for each graph
num_edge = sum(cellfun(@(x) sum(x(:))/2,A));

fprintf('***************************** Model Summary *****************************\n')
fprintf('The number of graphs: %d\n',n);
fprintf('The total number of nodes: %d\n',sum(m));
fprintf('The total number of edges: %d\n',num_edge);
fprintf('*************************************************************************\n')


display('----------------------------------------------------------------------')
dispstat('','init')
dispstat('Begining the process of preprocessing...','keepthis','timespamp'); 
if (nargin == 7)
    d = cell(length(A),1);
end

L = cellfun(@(x) diag(sum(x,2))-x, A, 'UniformOutput',false); % the graph laplacian 

% get the correspondences matrix from the labels;
[B,D] = group2group_map(label,n,m);

%d = cell(n,1);  % graph distances to preserve
mu = ones(n);   % weight for the second term
w = cell(n,1);  % weights for the third term

if (nargin == 7)
    dispstat('Started: calculate graph distance d.','timestamp','keepthis')
    for i =  1:n
        dispstat(sprintf('Processing %d%%',100*i/n),'timestamp'); 
        
        d{i} = A{i};
        d{i}(d{i} == 0) = Inf;
        d{i} = FastFloyd(d{i});
    end
    dispstat('Finished: calculate graph distance d','keepprev');
end

for i = 1:n
    w{i} = c2./d{i}.^2 +  c3*A{i};
end

A2 = A;
d2 = d;
% if c4 != 1, update the distance matrix to bring the nodes with the
% same label closer
if(c4 ~= 1 && nargin == 7) 
    dispstat('Started: update graph distance','timestamp','keepthis')
    for i = 1:n
        dispstat(sprintf('Processing %d%%',100*i/n),'timestamp'); 
        uni_l = unique(label{i});
        for j = 1:length(uni_l)
            A2{i}(label{i} == uni_l(j),label{i} == uni_l(j)) = c4*d{i}(label{i} == uni_l(j),label{i} == uni_l(j));
        end
        d2{i} = A2{i};
        d2{i}(d2{i} == 0) = Inf;
        d2{i} = FastFloyd(d2{i});
    end  
    dispstat('Finished: update graph distance','keepprev');
end

graph.n = n;            % the number of graphs in the collection
graph.A = A;            % the adjacency matrix
graph.label = label;    % the labels for each node
graph.L = L;            % the graph laplacian
graph.B = B;            % the correspondence matrix
graph.D = D;            % the correspondence matrix
graph.X = X;            % separate kamada-kawai layout for each graph
graph.m = m;            % the number of nodes for each graph
graph.mu = c1*mu;       % the coefficient for the second term - consistency
graph.w = w;            % the coefficient for the third term - distance preservation
graph.d = d2;           % the pairwise graph distance to be preserved

dispstat('Finished: preprocessing','keepprev');
display('----------------------------------------------------------------------')
end

function [B,D] = group2group_map(label,n,m)

% group2group_map - use labels to find the correspondences
%
%   [B,D] = group2group_map(label,n,m)
%
%   INPUT: 
%       label:  the label for each graph
%       n:      the number of graphs
%       m:      the number of nodes for each graph
%   OUTPUT: correspondence B,D matrices
%       B{i,j}X_i ~ D{i,j}X_j: maps the i-th to the j-th graph
%
%   This function finds the mapping between two sets of labels, where the
%   center of the nodes with the same label in the first graph is mapped to
%   the center of the nodes with this label in the second graph

if (size(label{1},1) == 1 && size(label,2) == 1)
    all_label = cell2mat(label')';
elseif (size(label{1},2) == 1 && size(label,2) == 1)
    all_label = cell2mat(label);
end
tmp = num2cell(m);

B = cell(n,n); % constructed by rows
D = cell(n,n); % constructed by rows


dispstat('Started: B,D matrix construction','timestamp','keepthis')
for i = 1:n
    dispstat(sprintf('Processing %3.4f%%',100*i/n),'timestamp');
    % label for each cluster/unique label
    l = unique(label{i});
    % to store the center for each cluster
    cluster = zeros(length(l),length(label{i}));    
    for k = 1:length(l)
        cluster(k,:) = (label{i} == l(k))/sum(label{i} == l(k));
    end
    B_row = zeros(length(all_label),length(label{i}));
    for k = 1:length(l)
        id = (all_label == l(k));
        B_row(id,:) = repmat(cluster(k,:),sum(id),1);
    end
    B(i,1:n) = mat2cell(B_row,m,m(i))';    
    
    
    D_row = cellfun(@(x) eye(x),tmp,'UniformOutput',false);
    id = ~ismember(all_label,label{i});
    IND = mat2cell(id,m,1);

    for j = 1:n
        D_row{j}(IND{j},:) = zeros(sum(IND{j}),m(j));
        D{i,j} = D_row{j};
    end
end
dispstat('Finished: B,D matrix construction.','keepprev');
end



%--------------------------------------------------------------------------
% version 2.0
%--------------------------------------------------------------------------
% function [B,D] = group2group_map(label,n,m)
% 
% % group2group_map - use labels to find the correspondences
% %
% %   [B,D] = group2group_map(label,n,m)
% %
% %   INPUT: 
% %       label:  the label for each graph
% %       n:      the number of graphs
% %       m:      the number of nodes for each graph
% %   OUTPUT: correspondence B,D matrices
% %       B{i,j}X_i ~ D{i,j}X_j: maps the i-th to the j-th graph
% %
% %   This function finds the mapping between two sets of labels, where the
% %   center of the nodes with the same label in the first graph is mapped to
% %   the center of the nodes with this label in the second graph
% 
% B = cell(n,n);
% D = cell(n,n);
% dispstat('','init')
% dispstat('Begining the process of getting the B,D matrix...','keepthis','timespamp');
% dispstat('Started.','timestamp','keepthis')
% for i = 1:n
%     for j = 1:n
%         dispstat(sprintf('Processing %3.4f%%',100*((n-1)*i+j)/n^2),'timestamp');
%         B{i,j} = zeros(m(j),m(i));
%         D{i,j} = eye(m(j));
%         intsct = intersect(label{i},label{j});  % the shared labels
% 
%         tmp1 = ismember(label{i},intsct);
%         tmp2 = ismember(label{j},intsct);
% 
%         B{i,j}(tmp2,tmp1) = group_label_map(label{i}(tmp1),label{j}(tmp2));
%         D{i,j}(~tmp2,:) = 0;
%     end
% end
% dispstat('Finished.','keepprev');
% end 
% 
% 
% % label mapping from x to y
% function C = group_label_map(x,y)
%     m = length(x);
%     n = length(y);
%     C = zeros(n,m);
%     for i = 1:n
%         C(i,:) = (x == y(i)) / sum(x == y(i));
%     end
% end

%--------------------------------------------------------------------------
% version 1.0
%--------------------------------------------------------------------------

% function [B,D] = group2group_map(label,n,m)
%     B = cell(n,n);
%     D = cell(n,n);
%     for i = 1:n
%         for j = 1:n                
%             intsct = intersect(label{i},label{j});
%             B{i,j} = zeros(length(intsct),length(label{i}));        
%             D{i,j} = zeros(length(intsct),length(label{j}));
%             for k = 1:length(intsct)
%                 B{i,j}(k,:) = (label{i} == intsct(k))/sum(label{i} == intsct(k));           
%                 D{i,j}(k,:) = (label{j} == intsct(k))/sum(label{j} == intsct(k));        
%             end
%         end
%     end
% end
