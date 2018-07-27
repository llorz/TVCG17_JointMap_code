clc; close all; clear;
addpath('../func_JointMap/')
addpath('../func/')
% choose the dataset to test
model_name = 'Human';

[para,A,label,X] = set_parameters(model_name);
para.num_iter = 1e3;    % maximum iteration for the Joint Layout algorithm
[graph,new_x] = generateLayout(A,label,X,para);

%% test the diff_op defined on the target: visualization
s_id = 1;
[W,f] = get_diff_operator(graph,s_id,'target');
g = discretize_error(f,5,'value');  % discretize f into 5 categories

tmp = cell2mat(new_x);
fig_para.xMin = min(tmp(:,1)) - 0.1;
fig_para.xMax = max(tmp(:,1)) + 0.1;
fig_para.yMin = min(tmp(:,2)) - 0.1;
fig_para.yMax = max(tmp(:,2)) + 0.1;
fig_para.ctgMin = min(cell2mat(g));
fig_para.ctgMax = max(cell2mat(g));

figure
for i = 1:graph.n
    subplot(4,5,i)
    plot_graph_error(graph.A{i},new_x{i},label{i},g{i},num2str(i),fig_para)

end
%% test the diff_op defined on the source: sort the graphs
W = get_diff_operator(graph,s_id,'source');
vec_W = cell2mat(cellfun(@(x)x(:),W,'UniformOutput',false)')'; % vectorize the difference operator

[u,d,v] = svd(vec_W);
%u = u(:,1:rank(vec_W));
%diff_dist = squareform(pdist(u));
%C = unique(u,'rows');
diff_dist = squareform(pdist(vec_W));
[C,ia,ic] = unique(vec_W,'rows');   % gives cluster

close all
figure
scatter(u(:,1),u(:,2),'filled');hold on
for i = 1:size(C,1)
    ind = find(ismember(vec_W,C(i,:),'rows'));
    for j = 1:length(ind)
        text(u(ind(j),1)+ 0.001,u(ind(j),2)-(j-1)*0.05,num2str(ind(j)))
        %text(u(ind(j),1)+ (j-1)*0.009,u(ind(j),2),num2str(ind(j)))
    end
end

%%
n1 = 3; n2 = 4;
[~,iia] = sort(diff_dist(s_id,ia));
ind = ia(iia);
for j = 1:length(ind)
    if(mod(j,n1*n2) == 1)
        figure
        count = 1;
    end
    subplot(n1,n2,count)
    i = ind(j);
    plot_graph_error(graph.A{i},new_x{i},label{i},g{i},num2str(i),fig_para)
    graph_id = find(ic == ic(i));
    % check if the distance is the same
    if(isempty(unique(diff_dist(s_id,graph_id))))
        warning('The cluster with graph %d is wrong\n',i)
    end
    title({mat2str(find(ic == ic(i)));['distance: ' num2str(diff_dist(s_id,i))]})
    count = count + 1;
end
