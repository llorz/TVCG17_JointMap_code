function [para,A,label,X] = set_parameters(model_name)

%   set_parameters - set the parameters for the Joint Layout algorithm
%   
%   para = set_parameters(model_name)
%
%   Input: 
%       model_name: PSB dataset, scene, floorplan
%   OUTPUT: para 
%       c1 -- consistency
%       c2 -- preserve graph distances 
%       c3 -- preserve the distances of directly connected nodes
%       c4 -- for the nodes with the same label to get closer
%       n1,n2 -- figure size to plot the layout for the whole graph collection

dt_dir = '../data/';
switch model_name
    % PSB dataset
    case 'Ant'
        load([dt_dir,'psb_dataset/',model_name,'.mat']);
        c1 = 2; c2 = 100; c3 = 100; c4 = 0.6;
        n1 = 4; n2 = 5; num_iter = 1e3;
    case 'Airplane'
        load([dt_dir,'psb_dataset/',model_name,'.mat']);
        c1 = 2; c2 = 100; c3 = 100; c4 = 0.6;
        n1 = 4; n2 = 5; num_iter = 1e3;
    case 'FourLeg'
        load([dt_dir,'psb_dataset/',model_name,'.mat']);
        c1 = 2; c2 = 100; c3 = 100; c4 = 0.8;
        n1 = 4; n2 = 5; num_iter = 1e3;
    case 'Armadillo'
        load([dt_dir,'psb_dataset/',model_name,'.mat']);
        c1 = 2; c2 = 100; c3 = 100; c4 = 0.7;
        n1 = 4; n2 = 5; num_iter = 1e3;
      
    case 'Teddy'
        load([dt_dir,'psb_dataset/',model_name,'.mat']);
        c1 = 2; c2 = 100; c3 = 100; c4 = 0.7;
        n1 = 4; n2 = 5; num_iter = 1e3;
    case 'Human'
        load([dt_dir,'psb_dataset/',model_name,'.mat']);
        c1 = 2; c2 = 100; c3 = 100; c4 = 0.6;
        % paper: removes person 8
        A(8) = []; label(8) = []; X(8) = [];
        n1 = 4; n2 = 5; num_iter = 1e3;

    case 'scene'        
        load([dt_dir,model_name,'.mat']);
        % paper shows scene 2-4,6-8
        A([1,5]) = []; obj_label([1,5]) = []; X([1,5]) = [];
        label = obj_label;
        c1 = 20; c2 = 100; c3 = 100; c4 = 1;
        n1 = 2; n2 = 3; num_iter = 1e3;
    case 'floorplan'
        load([dt_dir,model_name,'.mat']);
        % paper shows floorplan 6-9
        A(1:5) = []; label(1:5) = []; X(1:5) = [];
        c1 = 12; c2 = 100; c3 = 100; c4 = 1;
        n1 = 2; n2 = 2; num_iter = 1e3;
    case 'food_network'
        load([dt_dir,model_name,'.mat']);
        c1 = 1e4; c2 = 100; c3 = 0; c4 = 1;
        n1 = 2; n2 = 2; X = new_x; num_iter = 1e3;
    
    % Stanford ShapeNet dataset
    case 'SNC_rocket'
        load([dt_dir,'ShapeNetCore/',model_name,'.mat']);
        c1 = 2; c2 = 500; c3 = 500; c4 = 0.7;
        n1 = 6; n2 = 11;    num_iter = 300;
        A = A_unweighted'; label = label'; X = x_unweighted;
    case 'SNC_motorcycle'
        load([dt_dir,'ShapeNetCore/',model_name,'.mat']);
        c1 = 2; c2 = 500; c3 = 100; c4 = 0.8;
        n1 = 7; n2 = 14; num_iter = 300;
        A = A_unweighted'; label = label'; X = x_unweighted;
    case 'SNC_airplane'
        load([dt_dir,'ShapeNetCore/',model_name,'.mat']);
        c1 = 1.2; c2 = 1000; c3 = 100; c4 = 0.9;
        n1 = 7; n2 = 14; num_iter = 50;
        A = A_unweighted'; label = label'; X = x_unweighted;
        % to save time, test less models
        A(201:end) = []; label(201:end) = []; X(201:end) = [];
    otherwise
        warning('dataset not found :C')
end
% model parameters
para.c1 = c1; para.c2 = c2; para.c3 = c3; para.c4 = c4;
% subfigure size
para.n1 = n1; para.n2 = n2; para.showfig = 1; para.showIni = 0;
% maximum iteration for the Joint Layout algorithm
para.num_iter = num_iter;
end