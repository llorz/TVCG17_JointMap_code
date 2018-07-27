function [graph,new_x,x0] = generateLayout(A,label,X,para)

% generateLayout - visualize the consistent layout for the given collection
%
%   [graph,new_x] = generateLayout(A,label,X,para)
%
%   INPUT: 
%       A:      the adjacency matrix for each graph in the collection
%       label:  the node label for each graph
%       X:      the separate layout for each graph, can be null
%       para: [c1,c2,c3,c4,n1,n2,num_iter]
%
%   This function is used to visualize the consistent layout for the given
%   colleciton: find the spectral initialization first, then use the stress
%   majorization to find the final layout.



% Step 00: preprocessing
tic
graph = preprocessing(A,label,X,para.c1,para.c2,para.c3,para.c4);
t0 = toc;
% Step 01: spectral drawing
tic
x0 = get_embedding(graph,graph.mu);
t1 = toc;
% Step 02: stress majorization
tic 
new_x = stress_majorization(graph,x0,para.num_iter);
t2 = toc;

fprintf('The runtime for preprocessing: %4.6f\n',t0);
fprintf('The runtime for spectral initialization: %4.6f\n',t1);
fprintf('The runtime for stress majorization: %4.6f\n',t2);
fprintf('The initial energy: %12.4f\n',total_energy(x0,graph)/1e4);
fprintf('The final energy: %12.4f\n',total_energy(new_x,graph)/1e4);
% plot the spectral initialization
if para.showIni 
    plot_layout(graph,X,para.n1,para.n2)
    set(gcf, 'name', 'Initial independent layout')
end
% plot the consistent layout
if para.showfig
    plot_layout(graph,new_x,para.n1,para.n2)
    set(gcf, 'name', 'final consistent layout')
end
end