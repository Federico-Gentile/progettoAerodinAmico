%%%% THIS IS THE OPTIMIZATION CYCLE %%%
clc
clear
close all

%% Choose airfoil parametrization and define lower and upper boundaries of design space
% IGP: x = [XT T rho0 betaTE], UM [- - - rad]  
% I valori massimi e minimi per i parametri rho0 e betaTE sono ottenuti scalando gli intervalli dei rispettivi valori adimensionali 
% per i valori massimi e minimi di XT e T.  
% Reference: "An improved geometric parameter airfoil parameterizationmethod", Lu Xiaoqiang, Huang Jun, Song Lei, Li Jing (2018)
% lb      = [0.2002 0.0246 0.0026423 0.004465];    
% ub      = [0.4813 0.3227 0.67179   2.71165];

addpath('XFOIL')
% Lower and Upper boundary proposed by S.Bortolotti
system('')
lb      = [0.21 0.07 0.290  0.5];    
ub      = [0.4  0.25    0.9   3]; 
nvars   = 4; 

%% Optimization cycle

[x,fval,exitFlag,output] = particleswarm(@(x) fitness(x), nvars, lb, ub);