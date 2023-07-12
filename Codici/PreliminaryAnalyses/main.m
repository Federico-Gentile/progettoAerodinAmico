clear; close all; clc;
addpath('Functions\');

%% User defined inputs

% Blade root collectives list [deg]
inp.collList = [ 14 14 ];

% Blade type (0 rigid, 1 elastic)
inp.bladeType = [ 0 1 ]';

% Importing environment and rotor data
addpath('Data/');
environmentData;
rotorData;

% Importing aerodynamic data (use naca0012_CFD.mat as template)
inp.aeroDataset = 'naca0012_CFD.mat';
importAero;

% Inflow type (0 fixed, 1 variable), value in [m/s]
inp.inflowType = [ 1 1 ]';
inp.vi = [ 10.97 10.97 ]; 
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

clearvars -except inp rotData ambData aeroData structure

% Initializing outputs
results = struct();
[Tvec, Qvec, Pvec, viVec, timeVec] = deal(zeros(length(inp.collList),1));

for ii = 1:length(inp.collList)
    currColl = inp.collList(ii);
    currFieldName = "coll_" + strrep(num2str(currColl),'.','_');
    
    if inp.inflowType(ii)
        currFieldName = currFieldName + "i";
        % Computing inflow
        if inp.bladeType(ii) == 0
            currFieldName = currFieldName + "r";
            ftozero = @(vi, outFlag) solveRigidRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData);
        elseif inp.bladeType(ii) == 1
            currFieldName = currFieldName + "e";
            ftozero = @(vi, outFlag) solveElasticRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData, structure);           
        end
        tic
        [currVi, ~, exitFlag] = fsolve(@(vi) ftozero(vi, 0), inp.vi(ii), inp.options);
        runTime = toc;
        if exitFlag == 1
            [f, out] = ftozero(currVi, 1);
            out.f = f;
            out.vi = currVi;
            out.runTime = runTime;
            results.(currFieldName) = out;
        end
    else
        % Applying user defined inflow
        if inp.bladeType(ii) == 0
            currFieldName = currFieldName + "r";
            [f, out] = solveRigidRotor(inp.vi(ii), 1, currColl, inp, ambData, rotData, aeroData);
        elseif inp.bladeType(ii) == 1
            currFieldName = currFieldName + "e";
            [f, out] = solveElasticRotor(inp.vi(ii), 1, currColl, inp, ambData, rotData, aeroData, structure);
        end
        out.f = f;
        out.vi = inp.vi(ii);
        results.(currFieldName) = out;
    end

    % Output table
    Tvec(ii) = results.(currFieldName).T;
    Qvec(ii) = results.(currFieldName).Q;
    Pvec(ii) = results.(currFieldName).P;
    viVec(ii) = results.(currFieldName).vi;
    timeVec(ii) = results.(currFieldName).runTime;
    rowNames(ii) = currFieldName;
end

outTab = array2table([Tvec, Qvec, Pvec, inp.inflowType, viVec, inp.bladeType, timeVec]);
outTab.Properties.VariableNames = ["T [N]", "Q [Nm]", "P [hp]", "Real Infl?", "v_i [m/s]", "Elas?", "runTime"];
outTab.Properties.RowNames = rowNames;
outTab %#ok<NOPTS> 

clearvars out currColl currFieldName Tvec Qvec Pvec ftozero f ii

%% Plot section

if inp.plotResults
    plotResults;
end



