function [x_ini] = get_embedding(graph,mu)

%   get_embedding - find the spectral initialization
%
%   INPUT:
%       graph: the graph collection information
%       mu:    the penalty for consistency
%   OUTPUT:
%       x_ini: the spectral initial layout
%
%   This function is using the spectral decomposition method to find the
%   initialization layout for the graph collection



n = graph.n; L = graph.L;  B = graph.B; D = graph.D;
display('----------------------------------------------------------------------')
dispstat('','init')
dispstat('Begining the process of initialization...','keepthis','timespamp');

dispstat('Started.','timestamp','keepthis')
W = cellfun(@(x1,y1,x2,y2,mu) -mu*(x1'*y1 + y2'*x2),...
    B,D,B',D',num2cell(mu),...
    'UniformOutput',false);
dispstat('Finished: W matrix construction - stage 01.','timestamp','keepthis');

W2 = cellfun(@(x,y,mu) mu*(x'*x + y'*y),...
    B,D',num2cell(mu),...
    'UniformOutput',false);
dispstat('Finished: W matrix construction - stage 02.','timestamp','keepthis');

for i = 1:n
    dispstat(sprintf('Processing %3.4f%%',100*i/n),'timestamp');
    W{i,i} = sum(cat(3,W2{i,setdiff(1:n,i)}),3) + L{i}'*L{i}; 
end
W = cell2mat(W);

dispstat('Start: eigen-decomposition','timestamp','keepthis');
[v,~] = eigs(W,3,'sm');
dispstat('Finished:: eigen-decomposition','timestamp','keepthis');
x_ini = mat2cell(v(:,[2,1]),graph.m,2);
dispstat('Finished: spectral initialization','keepprev');
display('----------------------------------------------------------------------')
end

%--------------------------------------------------------------------------
% version 1.0
%--------------------------------------------------------------------------

% function [new_x] = get_embedding(graph,mu)
% 
% %   get_embedding - find the spectral initialization
% %
% %   INPUT:
% %       graph: the graph collection information
% %       mu:    the penalty for consistency
% %   OUTPUT:
% %       new_x: the spectral initial layout
% %
% %   This function is using the spectral decomposition method to find the
% %   initialization layout for the graph collection
% 
% 
% 
% n = graph.n; m = graph.m;
% L = graph.L;  B = graph.B; D = graph.D;
% 
% W = zeros(sum(m));
% tmp = [0;cumsum(m)];   % for indexing the W 
% 
% display('----------------------------------------------------------------------')
% dispstat('','init')
% dispstat('Begining the process of initialization...','keepthis','timespamp');
% dispstat('Started.','timestamp','keepthis')
% 
% for i = 1:n
%     for j = 1:n
%         dispstat(sprintf('Processing %3.4f%%',100*((n-1)*i+j)/n^2),'timestamp');
%         ind1 = (tmp(i)+1):tmp(i+1);
%         ind2 = (tmp(j)+1):tmp(j+1);
%         if (i == j)
%             for k = 1:n
%                 if(k ~= i)
%                     W(ind1,ind2) = W(ind1,ind2)+ mu(i,k)*(B{i,k}'*B{i,k} + D{k,i}'*D{k,i});
%                 end
%             end
%             W(ind1,ind2) = W(ind1,ind2) + L{i}'*L{i};
%         else
%             W(ind1,ind2) = -mu(i,j)*(B{i,j}'*D{i,j} + D{j,i}'*B{j,i});
%         end
%     end
% end
% dispstat('Finished.','keepprev');
% display('----------------------------------------------------------------------')
% % the spectral drawing
% [v,~] = eig(W);
% new_x = cell(n,1);     % positions for the embedding
% for i = 1:n
%     ind3 = (tmp(i)+1):tmp(i+1);
%     new_x{i} = v(ind3,2:3);
% end
% end