clear; close all; clc;

%% User defined inputs

% Blade root collectives list [deg]
inp.collList = [ 14 14 15.3 15.3 16.6 16.6 18 18];

% Importing environment and rotor data
addpath('Data/');
environmentData;
rotorData;

% Importing aerodynamic data (use naca0012_CFD.mat as template)
inp.aeroDataset = 'naca0012_CFD.mat';
importAero;

% Inflow type (0 fixed, 1 variable), value in [m/s]
inp.inflowType = [ 0 1 0 1 0 1 0 1 ]';
inp.vi = [ 10.97 10.97 10.97 10.97 10.97 10.97 10.97 10.97]; 
inp.options = optimoptions('fsolve', 'Display', 'off');

% Number of sections along the blade for loads computation
inp.Nsega = 50;

% Plot options
inp.plotResults = 1;

%% Computations

% Retrieving load computation points position [m]
inp.x = linspace(0, rotData.R, inp.Nsega)';

% Initializing outputs
results = struct();
[Tvec, Qvec, Pvec, viVec] = deal(zeros(length(inp.collList),1));

for ii = 1:length(inp.collList)
    currColl = inp.collList(ii);
    
    if inp.inflowType(ii)
        currFieldName = "coll_" + strrep(num2str(currColl),'.','_') + "i";
        % Computing inflow
        ftozero = @(vi) solveRotor(vi, 0, currColl, inp, ambData, rotData, aeroData);
        [currVi, ~, exitFlag] = fsolve(ftozero, inp.vi(ii), inp.options);
        if exitFlag == 1
            [f, out] = solveRotor(currVi, 1, currColl, inp, ambData, rotData, aeroData);
            out.f = f;
            out.vi = currVi;
            results.(currFieldName) = out;
        end
    else
        currFieldName = "coll_" + strrep(num2str(currColl),'.','_');
        % Applying user defined inflow
        [f, out] = solveRotor(inp.vi(ii), 1, currColl, inp, ambData, rotData, aeroData);
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

outTab = array2table([Tvec, Qvec, Pvec, inp.inflowType, viVec]);
outTab.Properties.VariableNames = ["T [N]", "Q [Nm]", "P [hp]", "Real Infl?", "v_i [m/s]"];
outTab.Properties.RowNames = rowNames;
outTab %#ok<NOPTS> 

clearvars out currColl currFieldName Tvec Qvec Pvec ftozero f ii

%% Plot section

if inp.plotResults
    plotResults;
end



