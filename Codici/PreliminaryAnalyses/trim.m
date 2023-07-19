clear; close all; clc;

% Blade type (0 rigid, 1 elastic)
inp.bladeType = [0, 1];

%% User defined inputs

% Importing environment and rotor data
addpath('Data/'); addpath('Functions\');
environmentData;
rotorData;

% Importing aerodynamic data (use naca0012_CFD.mat as template)
inp.aeroDataset = 'naca0012_CFD.mat';
importAero;

% Aircraft weights list
inp.targetACw = linspace(rotData.EW, rotData.MTWO, 10);

% Collective [deg] and inflow velocity [m/s] initial guesses (+fsolve ops)
inp.coll0 = 10;
inp.vi0 = 10;
inp.options = optimoptions('fsolve', 'Display', 'off');

% Number of sections along the blade for loads computation (for rigid
% rotor)
inp.Nsega = 100;

% Plot options
inp.plotResults = 1;
inp.fontSize = 12;
inp.lineWidth = 2;

%% Computations

% Retrieving load computation points position [m]
inp.x = linspace(rotData.cutout, rotData.R, inp.Nsega)';

% Running elastic blade structure
if max(inp.bladeType) == 1
    % Initial guess for elastic rotor
    inp.q0 = zeros(rotData.No_c, 1);
    [structure, rotData] = structureElasticModel(rotData);
    % Interpolating modes on aerodynamic nodes
    for ii = 1:rotData.No_c
        structure.ModesgtInterpolated(ii,:) = interp1(structure.x, structure.Modesgt(ii,:,end), inp.x');
        structure.ModesgwInterpolated(ii,:) = interp1(structure.x, structure.Modesgw(ii,:,end), inp.x');
    end
end

clearvars -except inp rotData ambData aeroData structure

% Initializing outputs
results = struct();
collGuess = inp.coll0;
viGuess = inp.vi0;

[Qvec, Pvec, viVec, collVec] = deal(zeros(length(inp.bladeType), length(inp.targetACw)));

for ii = 1:length(inp.bladeType)
    if inp.bladeType(ii) == 0
        currBladeName = "RigidBlade";
    elseif inp.bladeType(ii) == 1
        currBladeName = "ElasticBlade";
    end

    switch currBladeName
        case 'RigidBlade'
            ftozeroInflow = @(vi, outFlag, currColl) solveRigidRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData);
        case 'ElasticBlade'
            ftozeroInflow = @(vi, outFlag, currColl) solveElasticRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData, structure);
    end

    for jj = 1:length(inp.targetACw)
        currACw = inp.targetACw(jj);
        ftozeroTrim = @(coll) solveTrim(coll, ftozeroInflow, viGuess, currACw, inp);
        currColl = fsolve(ftozeroTrim, collGuess, inp.options);
        [~, out] = ftozeroTrim(currColl);
        out.coll = currColl;

        % Saving results
        results.(currBladeName).("ACw_"+num2str(jj, '%i')) = out;
        Qvec(ii,jj) = out.Q;
        Pvec(ii,jj) = out.P;
        viVec(ii,jj) = out.vi;
        collVec(ii,jj) = out.coll;

        % Updating guess
        collGuess = currColl;
        viGuess = out.vi;
    end

    collGuess = inp.coll0;
    viGuess = inp.vi0;
end

%% Plot section

if inp.plotResults
    figure;
    
    subplot(2,2,1); hold on;
    plot(inp.targetACw, Qvec(1,:), '-r','DisplayName','Rigid Blade','LineWidth',inp.lineWidth);
    plot(inp.targetACw, Qvec(2,:), '-b','DisplayName','Elastic Blade','LineWidth',inp.lineWidth);
    legend('Location','best'); grid minor;
    xlabel('ACW [N]', 'FontSize', inp.fontSize);
    ylabel('Q [Nm]', 'FontSize', inp.fontSize);
    
    subplot(2,2,2); hold on;
    plot(inp.targetACw, Pvec(1,:), '-r','DisplayName','Rigid Blade','LineWidth',inp.lineWidth);
    plot(inp.targetACw, Pvec(2,:), '-b','DisplayName','Elastic Blade','LineWidth',inp.lineWidth);
    legend('Location','best'); grid minor;
    xlabel('ACW [N]', 'FontSize', inp.fontSize);
    ylabel('P [hp]', 'FontSize', inp.fontSize);
    
    subplot(2,2,3); hold on;
    plot(inp.targetACw, viVec(1,:), '-r','DisplayName','Rigid Blade','LineWidth',inp.lineWidth);
    plot(inp.targetACw, viVec(2,:), '-b','DisplayName','Elastic Blade','LineWidth',inp.lineWidth);
    legend('Location','best'); grid minor;
    xlabel('ACW [N]', 'FontSize', inp.fontSize);
    ylabel('vi [m/s]', 'FontSize', inp.fontSize);
    
    subplot(2,2,4); hold on;
    plot(inp.targetACw, collVec(1,:), '-r','DisplayName','Rigid Blade','LineWidth',inp.lineWidth);
    plot(inp.targetACw, collVec(2,:), '-b','DisplayName','Elastic Blade','LineWidth',inp.lineWidth);
    legend('Location','best'); grid minor;
    xlabel('ACW [N]', 'FontSize', inp.fontSize);
    ylabel('coll [deg]', 'FontSize', inp.fontSize);

end




