clear; close all; clc
addpath('../func/')
addpath('../func_JointMap/')
addpath('../data/')
addpath('E:/MATLAB_toolbox/other/')
addpath('E:/MATLAB_toolbox/matlab_bgl/')
addpath('E:/MATLAB_toolbox/toolbox_graph/')

person_id = reshape(repmat(1:10,10,1),[],1);
pose_id = repmat(1:10,1,10)';
%% pose graph: for each person, construct a graph of poses
% note: the mesh difference used here - without re-centering
load('FAUST_poses.mat')
x_mds = mdscale(dist_mat,2);
y = x_mds;
figure
gscatter(y(:,1),y(:,2),pose_id);hold on
title('graph of poses, MDS')

% for any two node, if have the same pose id, set to zero
d = dist_mat;
for i = 1:100
    d(i,pose_id == pose_id(i)) = 0;
end
y = mdscale(d,2);
figure
gscatter(y(:,1),y(:,2),pose_id)
title('graph of poses, MDS + set to zero')

w = ones(size(dist_mat));
w(d==0) = 10;
y = mdscale(d,2,'Weights',w);
figure
gscatter(y(:,1),y(:,2),pose_id)
title('graph of poses, MDS + set to zero, a = 10')


%% Joint Layout
c1 = 5; c2 = 0; c3 = 100; c4 = 1;

graph = preprocessing(A,label,X,c1,c2,c3,c4);
x0 = get_embedding(graph,graph.mu);
new_x = stress_majorization(graph,x0,2000);
y = cell2mat(new_x);
figure
gscatter(y(:,1),y(:,2),pose_id);hold on
for i = 1:10
    text(y(i,1),y(i,2),num2str(pose_id(i)))
end
title(['graph of poses, joint layout, consistency: ',num2str(c1)])

%% person graph: for each pose, construct a graph of persons
%load('../JointMap_code/data/FAUST_person.mat')
load('FAUST_person.mat')
x_mds = mdscale(dist_mat,2);
y = x_mds;
figure
gscatter(y(:,1),y(:,2),person_id);hold on
title('graph of persons, MDS')

% for any two node, if have the same pose id, set to zero
d = dist_mat;
for i = 1:100
    d(i,person_id == person_id(i)) = 0;
end
y = mdscale(d,2);
figure
gscatter(y(:,1),y(:,2),person_id)
title('graph of persons, MDS + set to zero')

w = ones(size(dist_mat));
w(d==0) = 10;
y = mdscale(d,2,'Weights',w);
figure
gscatter(y(:,1),y(:,2),person_id)
title('graph of persons, MDS + set to zero, a = 10')


%% Joint Layout
c1 = 5; c2 = 0; c3 = 100; c4 = 1;

graph = preprocessing(A,label,X,c1,c2,c3,c4);
x0 = get_embedding(graph,graph.mu);
new_x = stress_majorization(graph,x0,2000);
y = cell2mat(new_x);
figure
gscatter(y(:,1),y(:,2),cell2mat(graph.label'));hold on
for i = 1:10
    text(y(i,1),y(i,2),num2str(i))
end
title(['graph of persons, joint layout, consistency: ',num2str(c1)])