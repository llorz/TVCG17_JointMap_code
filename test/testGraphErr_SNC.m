clc; close all; clear;
addpath('../func_JointMap/')
addpath('../func/')

% model_name = 'SNC_motorcycle'; s_id = 37
% model_name = 'SNC_airplane'; s_id = 133;
model_name = 'SNC_rocket'; s_id = 16;
%% Joint Layout
[para,A,label,X] = set_parameters(model_name);
para.num_iter = 1000;
[graph,new_x] = generateLayout(A,label,X,para);
%% Source domain:
%s_id = 16; % rocket
%s_id = 37; % motorcycle 37, 54
%s_id = 133; % airplane: 31, 133

W = get_diff_operator(graph,s_id,'source');
% vectorize the difference operator
vec_W = cell2mat(cellfun(@(x)x(:),W,'UniformOutput',false)')'; 
[u,d,v] = svd(vec_W);
diff_dist = squareform(pdist(vec_W,'cityblock'));  % L1 norm
%diff_dist = squareform(pdist(vec_W));               % L2 norm
[C,ia,ic] = unique(vec_W,'rows');   % gives cluster

figure
scatter(u(:,1),u(:,2),'filled');hold on
for i = 1:size(C,1)
    ind = find(ismember(vec_W,C(i,:),'rows'));
    for j = 1:length(ind)
        %text(u(ind(j),1)+ 0.001,u(ind(j),2)-(j-1)*0.02,num2str(ind(j)))
        text(u(ind(j),1)+ (j-1)*0.009,u(ind(j),2),num2str(ind(j)))
    end
end

%% Target domain
[W,f] = get_diff_operator(graph,s_id,'target');
g = discretize_error(f,6,'value');  % discretize f into 5 categories

n1 = 5; n2 = 8;
tmp = cell2mat(new_x);
fig_para.xMin = min(tmp(:,1)) - 0.1;
fig_para.xMax = max(tmp(:,1)) + 0.1;
fig_para.yMin = min(tmp(:,2)) - 0.1;
fig_para.yMax = max(tmp(:,2)) + 0.1;
fig_para.ctgMin = min(cell2mat(g));
fig_para.ctgMax = max(cell2mat(g));

[~,iia] = sort(diff_dist(s_id,ia));
ind = ia(iia);
for j = 1:length(ind)
    if(mod(j,n1*n2) == 1)
        figure
        count = 1;
    end
    subplot(n1,n2,count)
    i = ind(j);
    plot_graph_error(graph.A{i},new_x{i},graph.label{i},g{i},num2str(i),fig_para)
    graph_id = find(ic == ic(i));
    % check if the distance is the same
    if(isempty(unique(diff_dist(s_id,graph_id))))
        warning('The cluster with graph %d is wrong\n',i)
    end
    title({mat2str(find(ic == ic(i)));['distance: ' num2str(diff_dist(s_id,i),'%2.2f')]})
    %find(ic == ic(i));
    count = count + 1;
end
