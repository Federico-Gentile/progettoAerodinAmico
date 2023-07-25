function [out, inp] = rotorSolution(x, aeroData, data, opts)


% Blade type (0 rigid, 1 elastic)
inp.bladeType = 0;

%% User defined inputs

% Importing environment and rotor data
addpath('Data/'); addpath('Functions\');
rotorData;

% Collective [deg] and inflow velocity [m/s] initial guesses (+fsolve ops)
inp.coll0 = 10;
inp.options = optimoptions('fsolve', 'Display', 'off');

% Number of sections along the blade for loads computation (for rigid
% rotor)
inp.Nsega = 100;
inp.tr = x(9);


%% Computations



% Retrieving load computation points position [m]
inp.x = linspace(rotData.cutout, rotData.R, inp.Nsega)';
inp.vi = interp1(rotData.r_Vi, rotData.Vi, inp.x, 'linear', 'extrap');

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
collGuess = inp.coll0;

if inp.bladeType == 0
    solveRotor = @(coll, outFlag) solveRigidRotor(coll, outFlag, inp, data, rotData, aeroData);
elseif inp.bladeType(ii) == 1
    solveRotor = @(coll, outFlag) solveElasticRotor(coll, outFlag, inp, data, rotData, aeroData, structure);
end

ftozeroTrim = @(coll) solveRotor(coll, 0);
currColl = fsolve(ftozeroTrim, collGuess, inp.options);
out = solveRotor(currColl, 1);
out.coll = currColl;

end