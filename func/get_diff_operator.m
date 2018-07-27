function [W,f] = get_diff_operator(graph,s_id,type)

% get_diff_operator - get the difference operator
%
% W  = get_diff_operator(graph,s_id,type)
%   INPUT:
%       graph: information about the graph collection
%       s_id:  source graph ID
%       type: 'source' or 'target' - where the operator defined
%   OUTPUT:
%       W: a matrix/difference operator for each graph
%
%   This function is used to find the difference operator for each pair of
%   (source, target_i) graph, where W{i} is a matrixs defined on the source
%   domain or the target domain, showing the differece between the source
%   and the target. W{i} defined on the source can be used to compare the
%   whole collection/or to sort the collection; W{i} define on the target
%   could be used to visualize the differences. 

n = graph.n;
%B_all = graph.B;
B_all = cellfun(@(x)x > 0,graph.B,'UniformOutput',false);

B_0j = cell(n,1);    B_jj = cell(n,1);  
B_j0 = cell(n,1);    B0 = B_all{s_id,s_id};
W = cell(n,1);  % the difference operator, defined on the source domain

L0 = graph.L{s_id}; 
L_j = cell(n,1);
for i = 1:n
    B_0j{i} = B_all{s_id,i};
    B_jj{i} = B_all{i,i};
    B_j0{i} = B_all{i,s_id};
    L_j{i} = graph.L{i};
    switch type
        case 'source'                
            W{i} = B0*L0*B0' - B_j0{i}*L_j{i}*B_j0{i}';
        case 'target'
            W{i} = B_0j{i}*L0*B_0j{i}' - B_jj{i}*L_j{i}*B_jj{i}';
        otherwise
            warning('Invalid input type')
    end
end   

% if type == target, calculate the error per node for the target graph
if(strcmp(type,'target'))
    f = cell(graph.n,1);
    k = 0;
    for s = 1:graph.n
        k = max(k,rank(W{s}));
    end
    for s = 1:graph.n
        [u,d] = eig(W{s});
        f{s} = zeros(size(W{s},1),1);
        [~,ic] = sort(abs(diag(d)),'descend');  % sort the absolute eigenvalue
        for p = 1:min(k,rank(W{s}))
            j = ic(p);
            f{s} = f{s} + abs(d(j,j))*u(:,j).^2;
        end
    end
end

end