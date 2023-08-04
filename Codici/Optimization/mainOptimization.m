clear; close all; clc;

%% Importing inputs
preProcess;
%% Optimization cycle

% [x,fval,exitFlag,output] = particleswarm(@(x) fitness(x, sett), sett.desVar.nVars, sett.desVar.LB, sett.desVar.UB);

%% Testing   x = [XT,T,rho0,betaTE]
% Upper and lower limits proposed by S. Bortolotti thesis
% % % XT ∈ [0.21, 0.4]
% % % T ∈ [0.07, 0.25]
% % % ρ0_nd ∈ [0.29, 0.9]
% % % βT_nd E ∈ [0.5, 3]
% x = [0.21 0.25 0.290  3]; % profilo ape maia per test codice
% x = [0.21 0.25 0.290 0.5]; % profilo goccia 1
% x = [0.4 0.25 0.290 0.5]; % profilo goccia 2
 x_root = [0.3 0.12 0.4322 2.022];  % simile al NACA0012
 x_tip = [0.3 0.12 0.4322 2.022];
 x = [ x_root, x_tip ];

fitness(x, sett)