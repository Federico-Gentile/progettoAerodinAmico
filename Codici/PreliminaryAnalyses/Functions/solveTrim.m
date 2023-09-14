function [f, out] = solveTrim(coll, ftozeroInflow, viGuess, currACw, inp)
%SOLVETRIM Summary of this function goes here
%   Detailed explanation goes here

% Computing thrust for requested collective value
if inp.uniformInflow
    [outVi, ~, exitFlag] = fsolve(@(vi) ftozeroInflow(vi, 0, coll), viGuess, inp.options);
    
    if exitFlag == 1
        [~, out] = ftozeroInflow(outVi, 1, coll);
        out.vi = outVi;
        T = out.T;
    else
        error('Inflow not converged');
    end
else
    [~, out] = ftozeroInflow(viGuess, 1, coll);
    out.vi = viGuess;
    T = out.T;
end

% Trim equation residual
f = T - currACw;

end

