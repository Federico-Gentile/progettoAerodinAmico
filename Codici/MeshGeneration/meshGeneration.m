clear; close all; clc;
addpath('../Optimization/functions');
addpath('../Optimization/coordinatesFiles');

% Mesh Generation User Defined Options
opts.meshEnumerationStartIndex = 19;
opts.meshTypeFlag = "RANS";
opts.x = [0.3 0.12 0.4322 2.022];  % simile al NACA0012
%opts.x = [0.01 0.02 0.1 0.1 0.21 0.21 0.4322 1]; % strange nose
%opts.x = [0.292145187452082,0.890818975485375,-0.023794010335273,0.161501024200541,0.332505262005317,0.137728997850190,0.406463454094145,1.570632482448465]; %G104 simile a un whitcomb
%opts.x = [0.2 0.4 0 0 0.4 0.25 0.29 0.5]; %G105 simile serie 6
% opts.x = [0.358441465911911,0.879746213196452,0,0,0.334590732839752,0.105356751786128,0.807968876579954,2.834983119393876]; %G106 goccia sottile
% opts.hList = 0.00658;
% opts.hList = 0.00439;
opts.hList = 0.015;
opts.R = 60;
%--------------------------------------------------------------------------

switch opts.meshTypeFlag
    case "Euler"
        opts.BL = 0;
    case "RANS"
        opts.BL = 1;
end

counter = -1;
for h = opts.hList

    % Updating mesh counter
    counter = counter + 1;

    % Defining mesh name
    folderName = strcat('meshG',num2str(opts.meshEnumerationStartIndex+counter,'%i'));
    su2MeshName = "meshG" + num2str(opts.meshEnumerationStartIndex+counter,'%i') + ".su2";
    geoMeshName = "meshG" + num2str(opts.meshEnumerationStartIndex+counter,'%i') + ".geo";
    
    % Generating .geo file
    geoCreationRefBox(opts.x,h,opts.R,opts.BL,geoMeshName)

    % Generating .su2 file
    meshCommand = "gmsh -format su2 " + geoMeshName + " -2";

    [status, result] = system('wsl ' + meshCommand);
    check(status, result);
    
    [status, result] = system('wsl mkdir outputMeshes/' + opts.meshTypeFlag + '/' + folderName);
    check(status, result);

    [status, result] = system('wsl mv ' + geoMeshName + ' outputMeshes/' + opts.meshTypeFlag + '/' + folderName);
    check(status, result);

    [status, result] = system('wsl mv ' + su2MeshName + ' outputMeshes/' + opts.meshTypeFlag + '/' + folderName);
    check(status, result);

end