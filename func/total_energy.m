function res = total_energy(X,para)
    L = para.L; D = para.D; B = para.B; n = para.n; mu = para.mu; w = para.w;d = para.d;
    % E1: smooth term
    res = norm(blkdiag(L{:})*blkdiag(X{:}),'fro')^2;
    % E2: consistency term
    for p = 1:n
        for q = 1:n
            if(p~=q)
                res = res + mu(p,q)*norm(B{p,q}*X{p} - D{p,q}*X{q},'fro')^2;
            end
        end
    end
    % E3: distance term
    for k = 1:n
        tmp = triu(w{k}.*(squareform(pdist(X{k})) - d{k}).^2,1);
        res = res + sum(tmp(:));
    end
end