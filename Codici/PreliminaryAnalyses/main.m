clear; close all; clc;
addpath('Functions\');

%% User defined inputs

% Inflow type 
% 1 for uniform inflow (computed with classic momentum theory)
% 0 for variable inflow (imported from dust) value in [m/s]
inp.uniformInflow = [ 1 1 ]';

% Blade root collectives list [deg] to be simulated
inp.collList = [ 11.5 12.5 ];

% Blade type (0 rigid, 1 elastic)
inp.bladeType = [ 1 1 ]';

% Importing environment and rotor data
addpath('Data/');
environmentData;
rotorData;

% Importing aerodynamic data (use naca0012_CFD.mat as template)
inp.aeroDataset = 'naca0012_CFD.mat';
importAero;

% Inflow velocity guess in [m/s]
inp.viGuess = [ 13.97 13.97 ]; 
inp.options = optimoptions('fsolve', 'Display', 'off');

% Number of sections along the blade for loads computation (for rigid
% rotor)
inp.Nsega = 100;

% Plot options
inp.plotResults = 1;

%% Computations

% Retrieving load computation points position [m]
inp.x = linspace(rotData.cutout, rotData.R, inp.Nsega)';

% Running elastic blade structure
if max(inp.bladeType)
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
[Tvec, Qvec, Pvec, viVec, timeVec, exitflag] = deal(zeros(length(inp.collList),1));
[UV, RE, rowNames] = deal(strings(length(inp.collList),1));

for ii = 1:length(inp.collList)
    currColl = inp.collList(ii);
    currFieldName = "coll_" + strrep(num2str(currColl),'.','_');
    
    if inp.uniformInflow(ii) % Uniform inflow
        currFieldName = currFieldName + "ui_";

        % Computing inflow
        if inp.bladeType(ii) == 0
            currFieldName = currFieldName + "r";
            ftozero = @(vi, outFlag) solveRigidRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData, inp.uniformInflow(ii));
            RE(ii) = 'Rigid';
        elseif inp.bladeType(ii) == 1
            currFieldName = currFieldName + "e";
            ftozero = @(vi, outFlag) solveElasticRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData, structure, inp.uniformInflow(ii));           
            RE(ii) = 'Elastic';
        end
        tic
        [currVi, ~, exitFlag] = fsolve(@(vi) ftozero(vi, 0), inp.viGuess(ii), inp.options);
        runTime = toc;

        [f, out] = ftozero(currVi, 1);
        out.f = f;
        out.vi = currVi;
        out.runTime = runTime;
        out.exitflag = exitFlag;
        results.(currFieldName) = out;

        UV(ii) = 'Uniform';

    else % DUST inflow
        currFieldName = currFieldName + "nui_";
        
        % Computing inflow distribution at current collective
        currVi = inflow.Finflow(repmat(currColl, length(inp.x), 1), inp.x);
       
        % Applying user defined inflow
        if inp.bladeType(ii) == 0
            currFieldName = currFieldName + "r";
            tic
            [f, out] = solveRigidRotor(currVi, 1, currColl, inp, ambData, rotData, aeroData, inp.uniformInflow(ii));
            runTime = toc;
            RE(ii) = 'Rigid';
        elseif inp.bladeType(ii) == 1
            currFieldName = currFieldName + "e";
            tic
            [f, out] = solveElasticRotor(currVi, 1, currColl, inp, ambData, rotData, aeroData, structure, inp.uniformInflow(ii));
            runTime = toc;
            RE(ii) = 'Elastic';
        end

        out.f = f;
        out.vi = mean(currVi);
        out.viDistr = currVi;
        out.runTime = runTime;
        out.exitflag = NaN;
        results.(currFieldName) = out;

        UV(ii) = 'DUST';
    end

    % Output table
    Tvec(ii) = results.(currFieldName).T;
    Qvec(ii) = results.(currFieldName).Q;
    Pvec(ii) = results.(currFieldName).P;
    viVec(ii) = results.(currFieldName).vi;
    timeVec(ii) = results.(currFieldName).runTime;
    exitflag(ii) = results.(currFieldName).exitflag;
    rowNames(ii) = currFieldName;
end

outTab = table(Tvec, Qvec, Pvec, UV, viVec, RE, timeVec, exitflag);
outTab.Properties.VariableNames = ["T [N]", "Q [Nm]", "P [hp]", "Inflow?", "v_i [m/s]", "Blade?", "runTime", "fsolveExitFlag"];
outTab.Properties.RowNames = rowNames;
outTab %#ok<NOPTS> 

clearvars out currColl currFieldName Tvec Qvec Pvec ftozero f ii timeVec exitflag

%% Plot section

if inp.plotResults
    plotResults;
end



