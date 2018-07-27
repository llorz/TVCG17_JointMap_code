function [] = plot_layout(graph,x,n1,n2)

% plot_layout - plot the layout for the whole graph collection
%
%   [] = plot_layout(graph,x,n1,n2)
%
%   INPUT: 
%       graph:  the information of each graph
%       x:      the graph layout
%       n1:     the number of rows for the figure
%       n2:     the number of cols for the figure
%
%   This function plot the layout for the whole graph collection, showing
%   n1*n2 subfigures in the same figure


A = graph.A;
l = graph.label;
tmp = cell2mat(x); 
a = 0.1;
MIN_x = min(tmp(:,1))-a; MAX_x = max(tmp(:,1))+a;
MIN_y = min(tmp(:,2))-a; MAX_y = max(tmp(:,2))+a;
for i = 1:graph.n
    if(mod(i,n1*n2) == 1)
        figure
        count = 1;
    end
    subplot(n1,n2,count)
    gplot(A{i},x{i})
    for k = 1:graph.m(i)
        text(x{i}(k,1),x{i}(k,2),num2str(l{i}(k)))
    end
    axis square
    axis off;
    axis([MIN_x,MAX_x,MIN_y,MAX_y]);
    title(num2str(i))
    count = count + 1;
end
    
end