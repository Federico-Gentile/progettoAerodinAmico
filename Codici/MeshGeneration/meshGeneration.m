clear; close all; clc;
addpath('../Optimization/functions');
addpath('../Optimization/coordinates');

% Mesh Generation User Defined Options
opts.meshEnumerationStartIndex = 26;
opts.meshTypeFlag = "RANS";
opts.x = [0.3 0.12 0.4322 2.022];  % simile al NACA0012
opts.hList = [0.009871875 0.00658125 0.0043875 0.002925 0.00195 0.0015];
opts.R = 60;

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