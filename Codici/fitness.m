function rotorPower = fitness(x)

%% Testing
x = [0.21 0.07 0.290  0.5];
%% File .geo creation
geo_creation(x)

%% Mesh creation
% Writing the wsl commands to generate the mesh
meshCommand = "gmsh -format su2 mesh.geo -2";

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

%% Launch CFD simulations
% Cycle through mach and alfa to create a Cl|Cd vs alpha|Ma table for the
% current profile
machVec = [0.5 0.6 0.7];
alfaVec = [3 6 9 12];
for ii = 1:length(machVec)
    for jj = 1:length(alfaVec)
        % Specify the WSL commands you want to execute
        wslCommands =  ["mpirun -n 8 SU2_CFD naca0012_JST.cfg",
            "sed -i ""s/AOA= " + num2str(alfaVec(jj)) + "/AOA= " + num2str(alfaVec(jj+1)) + "/"" naca0012_JST.cfg"];

        wslCommand = strjoin(wslCommands, '; ');
        % Launch WSL and execute the commands
        [status, result] = system('wsl ' + wslCommand);
        
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

    end    
end




%% Rotor power evaluation


end

