clear; close all; clc;

%% Importing inputs
preProcess;

% Optimization cycle

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
                               'MaxTime', sett.opt.maxTime, ...
                               'MinSurrogatePoints', sett.opt.minSurrPoints);
       [x,fval,exitflag,output,trials] = surrogateopt(@(x) fitness(x, sett), sett.desVar.LB, sett.desVar.UB, [],[],[],[],[], options);
       %[x,fval,exitflag,output,trials] = surrogateopt("checkPointFile.mat", options);
       save('workspace.mat')
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
% x_root = [0.3 0.12 0.4322 2.022];  % simile al NACA0012
% x_tip = [0.3 0.12 0.4322 2.022];

% x_root = [ 0.4 0.25 0.29 0.5 ]; % G105
% x_tip = [ 0.4 0.25 0.29 0.5 ]; % G105

% x_root = [ 0.334590732839752,0.105356751786128,0.807968876579954,2.834983119393876 ]; % G106
% x_tip = [ 0.334590732839752,0.105356751786128,0.807968876579954,2.834983119393876 ]; % G106

% x = [0.340633	0.182205	0.761005	3.000000	0.210000	0.198494	0.751872	2.165094]; % profilo 1 debuggato
% x = [0.352547	0.178457	0.677464	1.286552	0.344831	0.142781	0.891129	2.520701]; %  profilo 2 debuggato
% 
% x = [0.21 0.1509 0.29 0.5 0.3114 0.1115 0.29 0.7319];
% [P, out, out_xfoil_root] = fitness(x, sett);

% close all; 
% 
% figure;
% subplot(2,3,1)
% plot(sett.rotSol.x, out.alpha); hold on;
% yline(max(max(sett.stencil.alphaGridCFD)));
% yline(min(min(sett.stencil.alphaGridCFD)));
% ylabel('alpha')
% subplot(2,3,2)
% plot(sett.rotSol.x, out.cl)
% ylabel('cl')
% subplot(2,3,3)
% plot(sett.rotSol.x, out.cd)
% ylabel('cd')
% subplot(2,3,4)
% plot(sett.rotSol.x, out.Fz)
% ylabel('Fz')
% subplot(2,3,5)
% plot(sett.rotSol.x, out.Fx)
% ylabel('Fx')
% 
% alphaGridAugmented = [ sett.stencil.alphaGridCFD(1,:)-3;
%                        sett.stencil.alphaGridCFD(1,:)-1.5; 
%                        sett.stencil.alphaGridCFD;
%                        sett.stencil.alphaGridCFD(end,:)+1.5;
%                        sett.stencil.alphaGridCFD(end,:)+3];
% 
% machGridAugmented = [ sett.stencil.machGridCFD(1:4,:);
%                         sett.stencil.machGridCFD];
% 
% figure;
% subplot(1,2,1); hold on;
% surf(sett.stencil.machGridCFD, sett.stencil.alphaGridCFD, out.aeroData{2}.cl(sett.stencil.machGridCFD', sett.stencil.alphaGridCFD')', 'FaceColor', 'b', 'FaceAlpha', 0.5);
% surf(machGridAugmented, alphaGridAugmented, out.aeroData{2}.cl(machGridAugmented', alphaGridAugmented')', 'FaceColor', 'r', 'FaceAlpha', 0.5);
% zlabel('cl');
% subplot(1,2,2); hold on;
% surf(sett.stencil.machGridCFD, sett.stencil.alphaGridCFD, out.aeroData{2}.cd(sett.stencil.machGridCFD', sett.stencil.alphaGridCFD')', 'FaceColor', 'b', 'FaceAlpha', 0.5);
% surf(machGridAugmented, alphaGridAugmented, out.aeroData{2}.cd(machGridAugmented', alphaGridAugmented')', 'FaceColor', 'r', 'FaceAlpha', 0.5);
% zlabel('cd');
% 
% figure; 
% subplot(1,2,1); hold on;
% scatter3(out_xfoil_root.mach, out_xfoil_root.alpha, out.aeroData{1}.cl(out_xfoil_root.mach, out_xfoil_root.alpha));
% zlabel('cl');
% subplot(1,2,2); hold on;
% scatter3(out_xfoil_root.mach, out_xfoil_root.alpha, out.aeroData{1}.cd(out_xfoil_root.mach, out_xfoil_root.alpha));
% zlabel('cd');







