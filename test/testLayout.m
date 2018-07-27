% % INPUT:
%   A:            A{i} gives the adjacency matrix of i-th graph
%   label:        label{i} the labels for each node in the i-th graph
%   X(optional):  the individual layout for each graph
%   parameters:
%       c1 -- consistency
%       c2 -- preserve graph distances 
%       c3 -- preserve the distances of directly connected nodes
%       c4 -- for the nodes with the same label to get closer
%       n1,n2 -- figure size to plot the layout for the whole graph collection
%       num_iter -- the maximum number of iterations for stress majorization
%       showIni -- if show the initial independent layout
%       showfig -- if show the final consistent layout

clc; close all; clear;
addpath('../func_JointMap/')
addpath('../func/')
%% choose the dataset to test
% Stanford SNC: 'SNC_motorcycle', 'SNC_airplane', 'SNC_rocket'
% PSB: 'Ant' 'Airplane','FourLeg','Armadillo','Teddy', 'Human'
% other dataset: 'scene', 'floorplan', 'food network'  

model_name = 'Armadillo'; 
% set parameters consistent with paper
[para,A,label,X] = set_parameters(model_name);
% generate the consistent layout
[graph,new_x] = generateLayout(A,label,X,para);

%% load other dataset
% % load your dataset with input A, label, X
% load('../data/psb_dataset/Ant.mat');
% % set your parameters
% para.c1 = 2; para.c2 = 100; para.c3 = 100; para.c4 = 0.6;
% para.n1 = 4; para.n2 = 5;  para.num_iter = 1e3;
% para.showIni = 1;
% para.showfig = 1; 
% % generate the consistent layout
% [graph,new_x] = generateLayout(A,label,X,para);

