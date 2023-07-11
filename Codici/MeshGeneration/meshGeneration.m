clear; close all; clc;
addpath('../Optimization/functions');

opts.meshEnumerationStartIndex = 26;
opts.meshTypeFlag = "RANS";
opts.x = [0.3 0.12 0.4322 2.022];  % simile al NACA0012
opts.hList = [0.009871875 0.00658125 0.0043875 0.002925 0.00195 0.0015 ];
opts.R = 60;

switch meshTypeFlag
    case "Euler"
        opts.BL = 0;
    case "RANS"
        opts.BL = 1;
end

counter = 0;
for h = opts.hList
    counter = counter + 1;
    geoMeshName = strcat('meshG',num2str(opts.meshEnumerationStartIndex+counter,'%i'),'.geo');

    geoCreationRefBox(opts.x,h,opts.R,opts.BL,geoMeshName)

    meshCommand = "gmsh -format su2 " + geoMeshName + " -2";

    % Launch WSL and execute the command
    [status, result] = system('wsl ' + meshCommand);
    % Check the status and display the result
    if status == 0
        disp('WSL commands executed successfully.');
        disp('Output:');
        disp(result);
    else
        disp('Failed to execute WSL commands.');
        disp('Error message:');
        disp(result);
    end
    
    folderName = strcat('meshG',num2str(opts.meshEnumerationStartIndex+counter,'%i'));
    su2MeshName = strcat('meshG',num2str(opts.meshEnumerationStartIndex+counter,'%i'),'.su2');
    [status, result] = system('wsl mkdir outputMeshes/' + opts.meshTypeFlag + '/' + folderName);
    if status == 0
        disp('WSL commands executed successfully.');
        disp('Output:');
        disp(result);
    else
        disp('Failed to execute WSL commands.');
        disp('Error message:');
        disp(result);
    end
    [status, result] = system('wsl mv ' + geoMeshName + ' outputMeshes/' + opts.meshTypeFlag + '/' + folderName);
    if status == 0
        disp('WSL commands executed successfully.');
        disp('Output:');
        disp(result);
    else
        disp('Failed to execute WSL commands.');
        disp('Error message:');
        disp(result);
    end
    [status, result] = system('wsl mv ' + su2MeshName + ' outputMeshes/' + opts.meshTypeFlag + '/' + folderName);
    if status == 0
        disp('WSL commands executed successfully.');
        disp('Output:');
        disp(result);
    else
        disp('Failed to execute WSL commands.');
        disp('Error message:');
        disp(result);
    end


end