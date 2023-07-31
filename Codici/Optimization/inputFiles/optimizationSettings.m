
% Importing environment data
environmentData;

% Importing rotor data
rotData.bladeType = 0; % 0 rigid, 1 elastic
rotorData;

% Blending criterium setting
sett.blending.A = 0.05; % amplitude of the blending region (over rotor radius)

% Design variable data
sett.desVar.switchPoint = 0.75;
sett.desVar.switchMach = sett.desVar.switchPoint*rotData.R*rotData.omega/ambData.c;
sett.desVar.LB = [ 0.21 0.07 0.290  0.5 0.21 0.07 0.290  0.5 ]; % From Bortolotti
sett.desVar.UB = [ 0.4  0.25    0.9   3 0.4  0.25    0.9   3 ]; % From Bortolotti
sett.desVar.nVars = 8;

% RANS mesh setting
sett.mesh.h_fine = 0.00439; % G22
sett.mesh.h_coarse = 0.015; % G19
sett.mesh.H = 20; 
sett.mesh.R = 60;
sett.mesh.BLflag = 1;

% XFOIL settings
sett.XFOIL.Npane = 200;
sett.XFOIL.tgapFlag = 0; % very dangerous, leave it to 0
sett.XFOIL.Ncrit = 4;
sett.XFOIL.machRoot = linspace((rotData.cutout*rotData.omega/ambData.c), ((sett.desVar.switchPoint-sett.blending.A)*rotData.R*rotData.omega/ambData.c), 10); 
sett.XFOIL.alphaRoot = 0:0.5:9; % deg

% RANS setting
sett.RANS.nproc = 2; % number of thread to run each RANS simulation
sett.RANS.maxThr = 18; % maximum number of threads involved in the optimization
sett.RANS.critPoint = [6, 0.6]; % [alpha, mach] point used for RANS correction

% Importing inflow data
inflow = load("inflow.mat");
[x,y] = meshgrid(inflow.bladeStations, inflow.Wac);
inflow.Finfl = griddedInterpolant(x', y', inflow.vi');
sett.inflow = inflow;
clearvars x y inflow

%
sett.ambData = ambData;
clear ambData;
sett.rotData = rotData;
clear rotData;

% Input checks
if length(sett.desVar.LB) ~= length(sett.desVar.UB)
    error('Forza Latifi')
elseif length(sett.desVar.LB) ~= sett.desVar.nVars
    error('Forza Verstappen')
elseif max(sett.desVar.LB>=sett.desVar.UB) == 1 
    error('Forza Hamilton')
end