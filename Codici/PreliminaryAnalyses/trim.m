clear; clc; close all;

% Blade type (0 rigid, 1 elastic)
inp.bladeType = [0, 1];

%% User defined inputs

% Importing environment and rotor data
addpath('Data/'); addpath('Functions\');
environmentData;
rotorData;

% Aircraft weights list
inp.targetACw = [85000];

% Inflow type 
% 1 for uniform inflow (computed with classic momentum theory)
% 0 for variable inflow (imported from dust) value in [m/s]
inp.uniformInflow = 0;

% Importing aerodynamic data (use naca0012_CFD.mat as template)
inp.aeroDataset = 'naca0012_RANS.mat';
importAero;

% Collective [deg] and inflow velocity [m/s] initial guesses (+fsolve ops)
inp.coll0 = 10.5;
inp.vi0 = 14;
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

% Initializing outputs
results = struct();
collGuess = inp.coll0;

[Qvec, Pvec, viVec, collVec] = deal(zeros(length(inp.bladeType), length(inp.targetACw)));

for ii = 1:length(inp.bladeType)
    
    % Defining blade type
    if inp.bladeType(ii) == 0
        currBladeName = 'RigidBlade';
        ftozeroInflow = @(vi, outFlag, currColl) solveRigidRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData, inp.uniformInflow);
    elseif inp.bladeType(ii) == 1
        currBladeName = 'ElasticBlade';
        ftozeroInflow = @(vi, outFlag, currColl) solveElasticRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData, structure, inp.uniformInflow);
    end

    for jj = 1:length(inp.targetACw)
        currACw = inp.targetACw(jj);

        if inp.uniformInflow % If uniform inflow, we apply the user defined guess
            viGuess = inp.vi0; 
        else % If DUST inflow, we compute distribution at current ACw
            viGuess = inflow.FinflowWac(repmat(currACw, length(inp.x), 1), inp.x);
        end
        
        % Solving trim equation
        ftozeroTrim = @(coll) solveTrim(coll, ftozeroInflow, viGuess, currACw, inp);
        currColl = fsolve(ftozeroTrim, collGuess, inp.options);
        [~, out] = ftozeroTrim(currColl);
        out.coll = currColl;

        % Saving results
        results.(currBladeName).("ACw_"+num2str(jj, '%i')) = out;
        Qvec(ii,jj) = out.Q;
        Pvec(ii,jj) = out.P;
        if inp.uniformInflow
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
            
            subplot(1,2,1); hold on;
            y = results.(currBladeName).("ACw_"+num2str(jj, '%i')).Fx;
            plot(x, y,'DisplayName','Rigid Blade','LineWidth',inp.lineWidth, 'DisplayName', "ACw_"+num2str(jj, '%i'));
            legend('Location','best'); grid minor;
            xlabel('mach', 'FontSize', inp.fontSize);
            ylabel('Fx [N/m]', 'FontSize', inp.fontSize);

            subplot(1,2,2); hold on;
            y = results.(currBladeName).("ACw_"+num2str(jj, '%i')).Fz;
            plot(x, y,'DisplayName','Rigid Blade','LineWidth',inp.lineWidth, 'DisplayName', "ACw_"+num2str(jj, '%i'));
            legend('Location','best'); grid minor;
            xlabel('mach', 'FontSize', inp.fontSize);
            ylabel('Fz [N/m]', 'FontSize', inp.fontSize);
            
        end
    end

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




