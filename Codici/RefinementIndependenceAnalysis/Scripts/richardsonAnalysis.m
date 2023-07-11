function [p, ext21, GCI21, GCI32, check, exitFlag, eqnVal] = richardsonAnalysis(r21, r32, f1, f2, f3, SF)
%RICHARDSONANALYSIS computes the expected practical convergence rate (with
%respect to the mesh discretization) starting from three force input values
%computed on three different grids
%grid1 is the finest, grid 3 is the coarsest

% QOI change over grids
e21 = f2 - f1;
e32 = f3 - f2;

% Intermediate quantities
s = sign(e32 - e21);
q = @(p) log( (r21.^p - s) ./ (r32.^p - s) );
eqn = @(p) p - abs( log( abs(e32 / e21) ) + q(p) ) / log(r21);

% Solving the equation for 'p'
options = optimoptions('fsolve', 'Display', 'off');
[p, eqnVal, exitFlag] = fsolve(eqn, 1, options);

% Richardson extrapolation
ext21 = f1 + (f1 - f2) / (r21^p - 1);

% GCIs of the two finest grids
GCI21 = SF * abs( (f1 - f2) / (f1 * (r21^p - 1) ) ) * 100;
GCI32 = SF * abs( (f2 - f3) / (f2 * (r32^p - 1) ) ) * 100;

% Computing final check
check = GCI32 / (GCI21 * r21^p);

end

