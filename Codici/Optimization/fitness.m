function P = fitness(x, sett)

x_root = x(1:4);
x_tip = x(5:8);

%% Meshes Creation (CFD)

% File .geo creation
geoCreationRefBox(x_tip, sett.mesh, sett.mesh.h_fine, "temporaryFiles/Gfine.geo");
geoCreationRefBox(x_tip, sett.mesh, sett.mesh.h_coarse, "temporaryFiles/Gcoarse.geo");

% Mesh creation
meshCommand = "gmsh -format su2 temporaryFiles/Gfine.geo -2 > temporaryFiles/fineMesh.log";
% system('start /B wsl ' + meshCommand);
system('wsl ' + meshCommand);
meshCommand = "gmsh -format su2 temporaryFiles/Gcoarse.geo -2 > temporaryFiles/coarseMesh.log";
system('wsl ' + meshCommand);

%% Blade root coefficients evaluation (XFOIL)

% Airfoil creation
airfoilCoordinatesXFOIL(x_root);

% Airfoil polar computation
out_xfoil_root = runXFOIL(sett);

aeroData{1}.cl = out_xfoil_root.Cl;
aeroData{1}.cd = out_xfoil_root.Cd;
aeroData{1}.cm = out_xfoil_root.Cm;

flag = 0;
while true && flag == 0
    if isfile('temporaryFiles/Gcoarse.su2') 
        flag = 1;
    end  
end
%% Launch CFD simulation
system('wsl ./shellScripts/main3.sh')

dummypause = 1;

%% Extracting Cl, Cd, Cm from CFD results
nCoarseSim = length(sett.stencil.alphaVec)+1;
clMat = zeros(size(sett.stencil.alphaGridCFD));
cdMat = zeros(size(sett.stencil.alphaGridCFD));
cmMat = zeros(size(sett.stencil.alphaGridCFD));
for ii = 1:nCoarseSim
    currAlpha = sett.stencil.alphaGridCFD(ii);
    currMach  = sett.stencil.machGridCFD(ii);
    tempString = "coarse_A" + strrep(num2str(currAlpha),'.','_') + "_M" + strrep(num2str(currMach),'.','_');
    history = readmatrix("CFDFiles\" + tempString + "\history_" + tempString);
    cdMat(ii) = history(end,10);
    clMat(ii) = history(end,11);
    cmMat(ii) = history(end,15);
end
% Fine sim coeffs extraction
tempString = "fine_A" + strrep(num2str(sett.stencil.alphaCorrectionPoint),'.','_') + "_M" + strrep(num2str(sett.stencil.machCorrectionPoint),'.','_');
history = readmatrix("CFDFiles\" + tempString + "\history_" + tempString);
cdFine = history(end,10);
clFine = history(end,11);
cmFine = history(end,15);

%% Correction 
ratioCd = cdFine/cdMat(sett.stencil.indCorrectionPoint);
ratioCl = clFine/clMat(sett.stencil.indCorrectionPoint);
ratioCm = cmFine/cmMat(sett.stencil.indCorrectionPoint);

cdMat = cdMat * ratioCd;
clMat = clMat * ratioCl;
cmMat = cmMat * ratioCm;

% Gridded Interpolant Creation for the tip airfoil
aeroData{2}.cd = griddedInterpolant(sett.stencil.machGridCFD', sett.stencil.alphaGridCFD', cdMat', 'linear');
aeroData{2}.cl = griddedInterpolant(sett.stencil.machGridCFD', sett.stencil.alphaGridCFD', clMat', 'linear');
aeroData{2}.cm = griddedInterpolant(sett.stencil.machGridCFD', sett.stencil.alphaGridCFD', cmMat', 'linear');

%% Rotor Power Evaluation
[out] = rotorSolution(sett, aeroData);
P = out.P;

end