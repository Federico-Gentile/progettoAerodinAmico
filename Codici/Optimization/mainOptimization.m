clear; close all; clc;

%% Importing inputs
preProcess;

%% Optimization cycle

switch sett.opt.ID
    case 'PSO'
        options = optimoptions('particleswarm','FunctionTolerance', sett.opt.functionTolerance,...
                                'FunValCheck', sett.opt.funValCheck,...
                                'MaxIterations', sett.opt.maxIterations,...
                                'MaxStallIterations', sett.opt.maxStallIterations,...
                                'MaxStallTime', sett.opt.maxStallTime,...
                                'MaxTime', sett.opt.maxTime,...
                                'SwarmSize', sett.opt.swarmSize);
        [xOpt, fval, exitFlag, output] = particleswarm(@(x) fitness(x, sett), sett.desVar.nVars, sett.desVar.LB, sett.desVar.UB, options);
    case 'GA'
        error('Not implemented')

    case 'SU'
        options = optimoptions('surrogateopt', 'CheckpointFile',  sett.opt.checkPointFile, ...
                               'MaxFunctionEvaluations', sett.opt.maxFunctionEvaluations, ...
                               'MaxTime', sett.opt.maxTime);
       [x,fval,exitflag,output,trials] = surrogateopt(@(x) fitness(x, sett), sett.desVar.LB, sett.desVar.UB, [],[],[],[],[], options);
end

%% Testing   x = [XT,T,rho0,betaTE]
% Upper and lower limits proposed by S. Bortolotti thesis
% % % XT ∈ [0.21, 0.4]
% % % T ∈ [0.07, 0.25]
% % % ρ0_nd ∈ [0.29, 0.9]
% % % βT_nd E ∈ [0.5, 3]
% x = [0.21 0.25 0.290  3]; % profilo ape maia per test codice
% x = [0.21 0.25 0.290 0.5]; % profilo goccia 1
% x = [0.4 0.25 0.290 0.5]; % profilo goccia 2
% 
%  x_root = [0.3 0.12 0.4322 2.022];  % simile al NACA0012
%  x_tip = [0.3 0.12 0.4322 2.022];

%  x_root = [ 0.4 0.25 0.29 0.5 ]; % G105
%  x_tip = [ 0.4 0.25 0.29 0.5 ]; % G105

%  x_root = [ 0.334590732839752,0.105356751786128,0.807968876579954,2.834983119393876 ]; % G106
%  x_tip = [ 0.334590732839752,0.105356751786128,0.807968876579954,2.834983119393876 ]; % G106
% 
%  x = [ x_root, x_tip ];
% % % 
% sett.optIter = 0;
%  P = fitness(x, sett);