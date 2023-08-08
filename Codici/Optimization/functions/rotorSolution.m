function [out] = rotorSolution(sett, aeroData)

% Running elastic blade structure
if max(sett.rotSol.bladeType) == 1
    % Initial guess for elastic rotor
    sett.rotSol.q0 = zeros(sett.rotData.No_c, 1);
    [structure, sett.rotData] = structureElasticModel(sett.rotData);
    % Interpolating modes on aerodynamic nodes
    for ii = 1:sett.rotData.No_c
        structure.ModesgtInterpolated(ii,:) = interp1(structure.x, structure.Modesgt(ii,:,end), sett.rotSol.x');
        structure.ModesgwInterpolated(ii,:) = interp1(structure.x, structure.Modesgw(ii,:,end), sett.rotSol.x');
    end
end

% Initializing outputs
collGuess = sett.rotSol.coll0;

if sett.rotSol.bladeType == 0
    solveRotor = @(coll, outFlag) solveRigidRotor(coll, outFlag, sett, aeroData);
elseif sett.rotSol.bladeType(ii) == 1
    solveRotor = @(coll, outFlag) solveElasticRotor(coll, outFlag, inp, data, rotData, aeroData, structure);
end

ftozeroTrim = @(coll) solveRotor(coll, 0);
[currColl, fval, exitflag] = fsolve(ftozeroTrim, collGuess, sett.rotSol.options);
out = solveRotor(currColl, 1);
out.coll = currColl;
out.ftosolveVal = fval;
out.exitflag = exitflag;

end