clear; close all; clc;

% Blade type (0 rigid, 1 elastic)
inp.bladeType = [0, 1];

%% User defined inputs

% Importing environment and rotor data
addpath('Data/'); addpath('Functions\');
environmentData;
rotorData;

% Importing aerodynamic data (use naca0012_CFD.mat as template)
inp.aeroDataset = 'naca0012_RANS.mat';

% Aircraft weights list
inp.targetACw = [50358.1360806500
                 67892.2562789325
                 76844.5887707531
                 85499.0933112012
                 93746.8741853770];

% Collective [deg] and inflow velocity [m/s] initial guesses (+fsolve ops)
inp.momentumTheory = 0;
inp.coll0 = 10;
inp.vi0 = 10;
inp.options = optimoptions('fsolve', 'Display', 'off');
inp.inflowDataset = 'inflow.mat';

% Number of sections along the blade for loads computation (for rigid
% rotor)
inp.Nsega = 500;

% Plot options
inp.plotResults = 1;
inp.fontSize = 12;
inp.lineWidth = 2;

%% Computations

importAero;

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

clearvars -except inp rotData ambData aeroData structure inflow

% Generating inflow lookup
if inp.momentumTheory
    viGuess = inp.vi0;
else
    [x,y] = meshgrid(inflow.bladeStations, inflow.Wac);
    inflow.Finfl = griddedInterpolant(x', y', inflow.vi');
    clearvars x y
end

% Initializing outputs
results = struct();
collGuess = inp.coll0;

[Qvec, Pvec, viVec, collVec] = deal(zeros(length(inp.bladeType), length(inp.targetACw)));

for ii = 1:length(inp.bladeType)
    if inp.bladeType(ii) == 0
        currBladeName = "RigidBlade";
    elseif inp.bladeType(ii) == 1
        currBladeName = "ElasticBlade";
    end
    
    switch currBladeName
        case 'RigidBlade'
            ftozeroInflow = @(vi, outFlag, currColl) solveRigidRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData, inp.momentumTheory);
        case 'ElasticBlade'
            ftozeroInflow = @(vi, outFlag, currColl) solveElasticRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData, structure, inp.momentumTheory);
    end

    for jj = 1:length(inp.targetACw)
        currACw = inp.targetACw(jj);

        if inp.momentumTheory == 0
            viGuess = inflow.Finfl(inp.x,currACw*ones(size(inp.x)));
        end

        ftozeroTrim = @(coll) solveTrim(coll, ftozeroInflow, viGuess, currACw, inp, inp.momentumTheory);
        currColl = fsolve(ftozeroTrim, collGuess, inp.options);
        [~, out] = ftozeroTrim(currColl);
        out.coll = currColl;

        % Saving results
        results.(currBladeName).("ACw_"+num2str(jj, '%i')) = out;
        Qvec(ii,jj) = out.Q;
        Pvec(ii,jj) = out.P;
        if inp.momentumTheory
            viVec(ii,jj) = out.vi;
        end
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

    for ii = 1:length(inp.bladeType)
        if inp.bladeType(ii) == 0
            currBladeName = "RigidBlade";
        elseif inp.bladeType(ii) == 1
            currBladeName = "ElasticBlade";
        end
        figure;
        for jj = 1:length(inp.targetACw)
            x = results.(currBladeName).("ACw_"+num2str(jj, '%i')).mach;
            
            subplot(2,2,1); hold on;
            y = results.(currBladeName).("ACw_"+num2str(jj, '%i')).alpha;
            plot(x, y,'DisplayName','Rigid Blade','LineWidth',inp.lineWidth, 'DisplayName', "ACw_"+num2str(jj, '%i'));
            legend('Location','best'); grid minor;
            xlabel('mach', 'FontSize', inp.fontSize);
            ylabel('alpha [deg]', 'FontSize', inp.fontSize);

            subplot(2,2,2); hold on;
            y = results.(currBladeName).("ACw_"+num2str(jj, '%i')).aIndu*180/pi;
            plot(x, y,'DisplayName','Rigid Blade','LineWidth',inp.lineWidth, 'DisplayName', "ACw_"+num2str(jj, '%i'));
            legend('Location','best'); grid minor;
            xlabel('mach', 'FontSize', inp.fontSize);
            ylabel('alpha_i [deg]', 'FontSize', inp.fontSize);

            subplot(2,2,3); hold on;
            y = results.(currBladeName).("ACw_"+num2str(jj, '%i')).cl;
            plot(x, y,'DisplayName','Rigid Blade','LineWidth',inp.lineWidth, 'DisplayName', "ACw_"+num2str(jj, '%i'));
            legend('Location','best'); grid minor;
            xlabel('mach', 'FontSize', inp.fontSize);
            ylabel('cl', 'FontSize', inp.fontSize);

            subplot(2,2,4); hold on;
            y = results.(currBladeName).("ACw_"+num2str(jj, '%i')).cd;
            plot(x, y,'DisplayName','Rigid Blade','LineWidth',inp.lineWidth, 'DisplayName', "ACw_"+num2str(jj, '%i'));
            legend('Location','best'); grid minor;
            xlabel('mach', 'FontSize', inp.fontSize);
            ylabel('cd', 'FontSize', inp.fontSize);
    
            
        end

    end


end




