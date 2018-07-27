function g = discretize_error(f,num,type)

% discretize_error - discretize graph error f
% INPUT:
%   f: graph error per node
%   num: discretize f into 'num' categories
%   tpye: find the categories by 'value' or 'quartile'
% OUTPUT:
%   g: discretized/categorized version of f with value 1,2,..., num

fsize = cellfun(@(x)length(x),f);
tmp = cell2mat(f);
tmp = (tmp - min(tmp))/(max(tmp) - min(tmp));   % normalize
switch type
    case 'value'
        q = 0:1/(num-1):1;
        q = [0,q + 1e-6];
    case 'quartile'        
        q = 0:1/(num-1):1;
        q(1) = [];
        tmp2 = tmp(tmp > 1e-6);
        q = quantile(tmp2,q);
        q = [0,1e-6,q];
    otherwise
        warning('Invalid input type')
end

f2 = discretize(tmp,q,'categorical',cellstr(categorical(0:num-1)));
g = str2double(cellstr(f2));
g = mat2cell(g,fsize,1);
end