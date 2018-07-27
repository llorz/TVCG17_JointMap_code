function [new_x] = stress_majorization(graph,x0,num_iter)

% stress_majorization - apply stress majorization to find the layout
%
%   layout = stress_majorization(graph,ini_layout,num_iter);
%
%   INPUT: 
%       graph:      adajency, laplacian, correspondence matrix, penalty...
%       ini_layout: initial layout from the spectral graph drawing
%       num_iter:   the maximum number of interations
%
%   This function is using the stress majorization method to find the
%   consistent layout for all the graphs


display('----------------------------------------------------------------------')
dispstat('','init')
dispstat('Begining the process of stress majorization...','keepthis','timespamp');

eps1 = 1.0e-3; % stop criterion

A = graph.A; mu = graph.mu; w = graph.w; d = graph.d;
n = length(A); m = graph.m; L = graph.L; B = graph.B; D = graph.D;

% the V matrix
dispstat('Started: V matrix construction.','timestamp','keepthis')
V = get_V(B,D,L,n,m,w,mu);
dispstat('Finished: V matrix construction.','timestamp','keepthis')
% V matrix is degenerate: because the layout is translation-invariant
% add a constraint that the center of the layout is(0,0)
% it's equivalent to set the last row of V to all ones
V(end,:) = 1;

m_ = sum(m);           % total num of nodes
tmp = [0;cumsum(m)];   % for indexing the W 
X = cell2mat(x0);

dispstat('Started: Stress majorization iteration.','timestamp','keepthis')
for it = 1:num_iter
    dispstat(sprintf('Processing %3.4f%%',100*it/num_iter),'timestamp');
    U = U_Z(X,w,d,n,m,m_,tmp);
    y = 2*U*X;
    y(end,:) = 0;   % the last row: added constraint, set center to (0,0)
    X1 = V\y; % X: previous layout; X1: updated layout
    
    if norm(X1 - X) < eps1     
        new_x = mat2cell(X1,graph.m,2);% reshape the layout
        fprintf('The number of iterations till convergence(g2g): %d\n',it)
        dispstat('Finished: stress majorization iteration (converged).','keepprev');
        display('----------------------------------------------------------------------')
        return
    end
    X = X1;
end
dispstat('Finished: stress majorizaiton iteration (not converged)','keepprev');
display('----------------------------------------------------------------------')

% not converged
new_x = mat2cell(X1,graph.m,2);
warning('Not converged yet :(')
return

end

% V matrix for the linear system: VX = UZ
function V = get_V(B,D,L,n,m,w,mu)
    L_w = cellfun(@(x) -x + diag(sum(x,2)), w,'UniformOutput',false);
    M = cell(n,1);
    N = cell(n,n);
    Q = cell(n,n);
    % M
    for k = 1:n
        M{k} = zeros(m(k));
        for p = 1:n
            if(p ~= k)
                M{k} = M{k} + mu(p,k)*D{p,k}'*D{p,k} + mu(k,p)*B{k,p}'*B{k,p};
            end
        end
        M{k} = 0.5*M{k} + L{k}'*L{k} + L_w{k};
    end

    % N, Q
    for p = 1:n
        N{p,p} = zeros(m(p));
        for k = 1:n
            if(k ~= p)
                N{p,k} = -mu(p,k)*B{p,k}'*D{p,k} - mu(k,p)*D{k,p}'*B{k,p};
                Q{p,k} = 0.5*(mu(p,k)*B{p,k}'*B{p,k} + mu(k,p)*D{k,p}'*D{k,p});
            end
        end
    end

    % V
    sum_Q = cell(n,1);
    for i = 1:n    
        catA=cat(3,Q{i,:});
        sum_Q{i} = sum(catA,3);   
    end
    V = blkdiag(M{:}) + cell2mat(N) + blkdiag(sum_Q{:});
    V = V + V';
end

% U matrix for the linear system: VX = UZ
function U = U_Z(Z,w,d,n,m,m_,tmp)
    U = zeros(m_);
    for k = 1:n
        ind = (tmp(k)+1):tmp(k+1);
        X = Z(ind,:);
        c = diag(X*X');
        dist = c*ones(1,m(k)) + ones(m(k),1)*c' - 2*X*X';
        dist = sqrt(dist);
%         dist = squareform(pdist(X));
        dist(dist < 1.0e-6) = 1.0e-6;
        p = -w{k}.*d{k}./dist;
        p(eye(size(p))~= 0) = 0;
        p(eye(size(p))~= 0) = -sum(p,2);
        U(ind,ind) = p;
    end
end

% function V = get_V(B,D,L,n,m,w,mu)
%     L_w = cellfun(@(x) -x + diag(sum(x,2)), w,'UniformOutput',false);
%     % M
%     M2 = cellfun(@(x,y,mu1,mu2) 0.5*(mu1*y'*y + mu2*x'*x),...
%         B',D,num2cell(mu),num2cell(mu)',...
%         'UniformOutput',false);
%     M2_sum = cell(n,1);
%     for i = 1:n
%         M2{i,i} = 0*M2{i,i};
%         M2_sum{i} = sum(cat(3,M2{:,i}),3);
%     end
%     M = cellfun(@(x,y,z) x'*x + y + z,...
%         L,M2_sum,L_w,...
%         'UniformOutput',false);
%     N = cellfun(@(x1,x2,y1,y2,mu1,mu2) -mu1*x1'*y1 - mu2*y2'*x2,...
%         B,B',D,D',num2cell(mu),num2cell(mu)',...
%         'UniformOutput',false);
%     Q = cellfun(@(x,y,mu1,mu2) 0.5*(mu1*x'*x + mu2*y'*y),...
%         B,D',num2cell(mu),num2cell(mu)',...
%         'UniformOutput',false);
%     % V
%     sum_Q = cell(n,1);
%     for i = 1:n    
%         Q{i,i} = zeros(size(Q{i,i}));
%         N{i,i} = zeros(size(N{i,i}));
%         sum_Q{i} = sum(cat(3,Q{i,:}),3);   
%     end
%     V = blkdiag(M{:}) + cell2mat(N) + blkdiag(sum_Q{:});
%     V = V + V';
% end

% function U = U_Z(Z,w,d,m)
% X = mat2cell(Z,m,2);
% % dist = cellfun(@(x) max(squareform(pdist(x)),1e-6),X,...
% %     'UniformOutput',false);
% W = cellfun(@(w,d,x) w.*d./max(squareform(pdist(x)),1e-6),...
%     w,d,X,...
%     'UniformOutput',false);
% W = cellfun(@(x) -x + diag(sum(x,2)),W,...
%     'UniformOutput',false);
% U = blkdiag(W{:});
% end