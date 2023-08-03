
%% Importing environment data
environmentData;

%% Importing rotor data
rotData.bladeType = 0; % 0 rigid, 1 elastic
rotorData;

%% Blending criterium setting
sett.blending.A = 0.05; % amplitude of the blending region (over rotor radius)

%% Design variable data
sett.desVar.switchPoint = 0.8;
sett.desVar.switchMach = sett.desVar.switchPoint*rotData.R*rotData.omega/ambData.c;
sett.desVar.LB = [ 0.21 0.07 0.290  0.5 0.21 0.07 0.290  0.5 ]; % From Bortolotti
sett.desVar.UB = [ 0.4  0.25    0.9   3 0.4  0.25    0.9   3 ]; % From Bortolotti
sett.desVar.nVars = 8;

%% Rotor solution settings
% Blade type (0 rigid, 1 elastic)
sett.rotSol.bladeType = 0;

% Collective [deg] and inflow velocity [m/s] initial guesses (+fsolve ops)
sett.rotSol.coll0 = 15.4587;  % NACA0012 collective trim
sett.rotSol.options = optimoptions('fsolve', 'Display', 'off');

% Number of sections along the blade for loads computation (for rigid rotor)
sett.rotSol.tr = sett.desVar.switchPoint * rotData.R;
sett.rotSol.Nsega = 100;
sett.rotSol.x = linspace(rotData.cutout, rotData.R, sett.rotSol.Nsega)';

%% RANS mesh setting
sett.mesh.h_fine = 0.00439; % G22
% sett.mesh.h_coarse = 0.015; % G19
sett.mesh.h_coarse = 0.01; % G20
% sett.mesh.H = 20; --> H is calculated as function of h and R in geoCreationRefBox.m
sett.mesh.R = 60;           % A value of R=60 is suggested for both domain independence considerations and smooth meshing using geoCreationRefBox.m
sett.mesh.BLflag = 1;       % 0 = No BL (Euler)   1 = BL (RANS)

%% XFOIL settings
sett.XFOIL.Npane = 200;
sett.XFOIL.tgapFlag = 0; % very dangerous, leave it to 0
sett.XFOIL.Ncrit = 4;
sett.XFOIL.machRoot = linspace((rotData.cutout*rotData.omega/ambData.c), ((sett.desVar.switchPoint-sett.blending.A)*rotData.R*rotData.omega/ambData.c), 10); 
sett.XFOIL.alphaRoot = 0:0.5:9; % deg

%% RANS simulation setting
sett.RANS.nproc = 2; % number of thread to run each RANS simulation
sett.RANS.maxThr = 18; % maximum number of threads involved in the optimization
sett.RANS.critPoint = [6, 0.6]; % [alpha, mach] point used for RANS correction

%% Importing inflow data
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