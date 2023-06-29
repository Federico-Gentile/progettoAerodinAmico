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

% NOTA: Ripetere 2 volte l'ultimo elemento per questioni di ciclo e
% verificare che il config sia inizializzato ai valori iniziali.
machVec = [0.5 0.6];  
alfaVec = [3 6];

s = readlines("naca0012_JST.cfg");
ind_aoa = find(strncmp(s, 'AOA', 3));
ind_mach = find(strncmp(s, 'MACH_NUMBER', 11));
for ii = 1:length(machVec)
    s{ind_mach} = ['MACH_NUMBER=' num2str(machVec(jj))];
    writelines(s, "naca0012_JST.cfg");
    for jj = 1:length(alfaVec)
        % Specify the WSL commands you want to execute
        s{ind_aoa} = ['AOA=' num2str(alfaVec(jj))];
        writelines(s, "naca0012_JST.cfg");
        % Launch WSL and execute the commands
        launchSim = "mpirun -n 8 SU2_CFD naca0012_JST.cfg";
        [status, result] = system('wsl ' + launchSim);
        
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

