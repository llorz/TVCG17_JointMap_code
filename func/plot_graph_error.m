function [] = plot_graph_error(A,x,label,error,fig_title,fig_para)

gplot(A,x);hold on
scatter(x(:,1),x(:,2),100,error,'filled'); hold on
for i = 1:length(label)
    text(x(i,1)+0.1,x(i,2),num2str(label(i)));hold on
end
axis square
caxis([fig_para.ctgMin, fig_para.ctgMax]);
axis([fig_para.xMin,fig_para.xMax,fig_para.yMin, fig_para.yMax]);
title(fig_title)
end