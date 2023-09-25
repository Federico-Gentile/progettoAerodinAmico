
%% Pre process

preProcess;

%% User defined inputs

% Root airfoil IGP coordinates
% x_root = [0.181574	0.127424	0.13 0.521235];  % Best root 
x_root = [0.38 0.12 0.36 1];
%x_root = [0.45	0.12	1.5		1.5];
% x_root = [0.283750	0.212813	0.154062	1.562500] ;
% x_root = [0.3 0.12 0.4322 2.022];  % simile al NACA0012
% Tip airfoil RANS lookup table
tipLookUp = 'aerodynamicDatabase\G71_RANS.mat';
tipProfileName = 'NACA64012';
saveflag = 1;
%% Blade root coefficients evaluation (XFOIL)

% Airfoil creation
airfoilCoordinatesXFOIL(x_root);

% Airfoil polar computation
out_xfoil_root = runXFOIL(sett);

% If XFOIL has failed to converge to a physical solution
if out_xfoil_root.failXFOIL ~= 0
    P = sett.penaltyPower;
    out.P = P;
    out.T = NaN;
    out.alpha = NaN;
    out.coll = NaN;
    out.exitflag = NaN;
    out.extrapFlagXFOIL = NaN;
    out.extrapFlagRANS = NaN;
    out.ClAtAlphaMax = NaN;
    out.CdAtAlphaMax = NaN;
    out.ClAtMidSpan = NaN;
    out.CdAtMidSpan = NaN;
    return
end

aeroData{1}.cl = out_xfoil_root.Cl;
aeroData{1}.cd = out_xfoil_root.Cd;
aeroData{1}.cm = out_xfoil_root.Cm;

%% Tip airfoil evaluation 

load(tipLookUp);  

% Creating interpolants
aeroData{2}.cl = griddedInterpolant(MACH_Cl', ANGLE_Cl', Cl', 'linear');
aeroData{2}.cd = griddedInterpolant(MACH_Cd', ANGLE_Cd', Cd', 'linear');
aeroData{2}.cm = griddedInterpolant(MACH_Cm', ANGLE_Cm', Cm', 'linear');

%% Rotor Power Evaluation
[out] = rotorSolution(sett, aeroData);
out.aeroData{1} = aeroData{1}; 
out.aeroData{2} = aeroData{2}; 

if out.exitflag > 0 && out.coll <= sett.collCheck
    P = out.P;
else
    P = sett.penaltyPower;
    out.P = P;
end

%% Check extrapolation

if max(out.alpha(1:sett.rotSol.ind1)) > max(sett.XFOIL.alphaRoot) || min(out.alpha(1:sett.rotSol.ind1)) < min(sett.XFOIL.alphaRoot)
    out.extrapFlagXFOIL = 1;
else
    out.extrapFlagXFOIL = 0;
end

if max(out.alpha(sett.rotSol.ind1+1:end)) > max(sett.stencil.alphaVec) || min(out.alpha(sett.rotSol.ind1+1:end)) < min(sett.stencil.alphaVec)
    out.extrapFlagRANS = 1;
else
    out.extrapFlagRANS = 0;
end

%% Extraction of coefficients of interest

% RANS point
[~, indAlphaMax] = max(out.alpha);  
out.ClAtAlphaMax = out.cl(indAlphaMax);
out.CdAtAlphaMax = out.cd(indAlphaMax);

% XFOIL point
[~, indMidSpan] = min(abs(sett.rotSol.x - (sett.rotSol.x(1) + (sett.rotSol.x(end) - sett.rotSol.x(1))/2)));
out.ClAtMidSpan = out.cl(indMidSpan);
out.CdAtMidSpan = out.cd(indMidSpan);
if saveflag
    save("out_"+tipProfileName,'out')
end
%% Plotting

figure;
subplot(2,3,1)
plot(sett.rotSol.x, out.alpha); hold on;
yline(max(max(sett.stencil.alphaGridCFD)));
yline(min(min(sett.stencil.alphaGridCFD)));
ylabel('alpha')
subplot(2,3,2)
plot(sett.rotSol.x, out.cl)
ylabel('cl')
subplot(2,3,3)
plot(sett.rotSol.x, out.cd)
ylabel('cd')
subplot(2,3,4)
plot(sett.rotSol.x, out.Fz)
ylabel('Fz')
subplot(2,3,5)
plot(sett.rotSol.x, out.Fx)
ylabel('Fx')

figure;
subplot(1,2,1); hold on;
[machTipGrid, alphaTipGrid] = ndgrid(out.mach(sett.rotSol.ind1+1:end), out.alpha(sett.rotSol.ind1+1:end));
surf(machTipGrid, alphaTipGrid, out.aeroData{2}.cl(machTipGrid, alphaTipGrid), 'FaceColor', 'b', 'FaceAlpha', 0.5);
zlabel('cl');
subplot(1,2,2); hold on;
surf(machTipGrid, alphaTipGrid, out.aeroData{2}.cd(machTipGrid, alphaTipGrid), 'FaceColor', 'b', 'FaceAlpha', 0.5);
plot3(out.mach(sett.rotSol.ind1+1:end), out.alpha(sett.rotSol.ind1+1:end), out.aeroData{2}.cd(out.mach(sett.rotSol.ind1+1:end), out.alpha(sett.rotSol.ind1+1:end)), 'r-', 'LineWidth', 2)
zlabel('cd');

% figure; 
% subplot(1,2,1); hold on;
% scatter3(out_xfoil_root.mach, out_xfoil_root.alpha, out.aeroData{1}.cl(out_xfoil_root.mach, out_xfoil_root.alpha));
% zlabel('cl');
% subplot(1,2,2); hold on;
% scatter3(out_xfoil_root.mach, out_xfoil_root.alpha, out.aeroData{1}.cd(out_xfoil_root.mach, out_xfoil_root.alpha));
% zlabel('cd');
