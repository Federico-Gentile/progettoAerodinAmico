function [p, ext21, GCI21, GCI32] = richardsonAnalysis(r21, r32, f1, f2, f3, componentName, SF)
%RICHARDSONANALYSIS computes the expected practical convergence rate (with
%respect to the mesh discretization) starting from three force input values
%computed on three different grids

% QOI change over grids
e21 = f2 - f1;
e32 = f3 - f2;

% Intermediate quantities
s = sign(e32 / e21);
q = @(p) log( (r21.^p - s) ./ (r32.^p - s) );
eqn = @(p) p - abs( log( abs(e32 / e21) ) + q(p) ) / log(r21);

% Solving the equation for 'p'
options = optimoptions('fsolve', 'Display', 'off');
[p, eqnVal, exitFlag, output] = fsolve(eqn, 1, options);

% Richardson extrapolation
ext21 = f1 + ( f1 - f2) / (r21^p - 1);

% GCIs of the two finest grids
ea21 = abs( (f1 - f2) / f1 );
ea32 = abs( (f2 - f3) / f2 );
GCI21 = SF * ea21 / (r21^p - 1);
GCI32 = SF * ea32 / (r32^p - 1);

% Computing final check
check = GCI32 / (GCI21 * r21^p);

fprintf('Results for ' + componentName + ' are: \n')
fprintf('  p: %.3f \n', p);
fprintf('  funVal: %.3f \n', eqnVal);
fprintf('  fsolve exitFlag: %i \n', exitFlag);
fprintf('  check: %.3f \n', check);

end

