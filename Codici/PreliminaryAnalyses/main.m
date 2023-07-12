clear; close all; clc;
addpath('Functions\');

%% User defined inputs

% Blade root collectives list [deg]
inp.collList = [ 14 14 16 16 18 18 ];

% Blade type (0 rigid, 1 elastic)
inp.bladeType = [ 0 1 0 1 0 1 ]';

% Importing environment and rotor data
addpath('Data/');
environmentData;
rotorData;

% Importing aerodynamic data (use naca0012_CFD.mat as template)
inp.aeroDataset = 'naca0012_CFD.mat';
importAero;

% Inflow type (0 fixed, 1 variable), value in [m/s]
inp.inflowType = [ 1 1 1 1 1 1 ]';
inp.vi = [ 10.97 10.97 10.97 10.97 10.97 10.97 ]; 
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
[Tvec, Qvec, Pvec, viVec] = deal(zeros(length(inp.collList),1));

for ii = 1:length(inp.collList)
    currColl = inp.collList(ii);
    currFieldName = "coll_" + strrep(num2str(currColl),'.','_');
    
    if inp.inflowType(ii)
        currFieldName = currFieldName + "i";
        % Computing inflow
        if inp.bladeType(ii) == 0
            currFieldName = currFieldName + "r";
            ftozero = @(vi) solveRigidRotor(vi, 0, currColl, inp, ambData, rotData, aeroData);
        elseif inp.bladeType(ii) == 1
            currFieldName = currFieldName + "e";
            ftozero = @(vi) solveElasticRotor(vi, 0, currColl, inp, ambData, rotData, aeroData, structure);
        end
        [currVi, ~, exitFlag] = fsolve(ftozero, inp.vi(ii), inp.options);
        if exitFlag == 1
            if inp.bladeType(ii) == 0
                [f, out] = solveRigidRotor(currVi, 1, currColl, inp, ambData, rotData, aeroData);
            elseif inp.bladeType(ii) == 1
                [f, out] = solveElasticRotor(currVi, 1, currColl, inp, ambData, rotData, aeroData, structure);
            end
            out.f = f;
            out.vi = currVi;
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
    rowNames(ii) = currFieldName;

end

outTab = array2table([Tvec, Qvec, Pvec, inp.inflowType, viVec, inp.bladeType]);
outTab.Properties.VariableNames = ["T [N]", "Q [Nm]", "P [hp]", "Real Infl?", "v_i [m/s]", "Elas?"];
outTab.Properties.RowNames = rowNames;
outTab %#ok<NOPTS> 

clearvars out currColl currFieldName Tvec Qvec Pvec ftozero f ii

%% Plot section

if inp.plotResults
    plotResults;
end



