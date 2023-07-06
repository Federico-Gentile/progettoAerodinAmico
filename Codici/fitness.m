% function rotorPower = fitness(x)
clc
clear
close
delete *.csv
delete *.dat
delete *.vtu
%% Testing   x = [XT,T,rho0,betaTE]
% Upper and lower limits proposed by S. Bortolotti thesis
% % % XT ∈ [0.21, 0.4]
% % % T ∈ [0.07, 0.25]
% % % ρ0_nd ∈ [0.29, 0.9]
% % % βT_nd E ∈ [0.5, 3]
% x = [0.21 0.25 0.290  3]; % profilo ape maia per test codice
% x = [0.21 0.25 0.290 0.5]; % profilo goccia 1
x = [0.4 0.25 0.290 0.5]; % profilo goccia 2
% x = [0.3 0.12 0.4322 2.022];  % simile al NACA0012
%% File .geo creation
geoCreation(x)

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

machVec = [0.52 0.55 0.58 0.61 0.64];  
alfaVec = [4 6 8 10];

% Double parallel running simulation
% % % s1 = readlines("naca0012_JST.cfg");
% % % s2 = readlines("naca0012_JST2.cfg");
% % % ind_aoa = find(strncmp(s1, 'AOA', 3));
% % % ind_mach = find(strncmp(s1, 'MACH_NUMBER', 11));
% % % Cl_mat = zeros(length(machVec), length(alfaVec));
% % % Cd_mat = zeros(length(machVec), length(alfaVec));
% % % Cm_mat = zeros(length(machVec), length(alfaVec));
% % % for ii = 1:length(machVec)
% % %     iter_m = ii;
% % %     s1{ind_mach} = ['MACH_NUMBER=' num2str(machVec(ii))];
% % %     s2{ind_mach} = ['MACH_NUMBER=' num2str(machVec(ii))];
% % %     writelines(s1, "naca0012_JST.cfg");
% % %     writelines(s2, "naca0012_JST2.cfg");
% % %     for jj = 1:2:length(alfaVec)
% % %         iter_a = jj;
% % %         % Update AOA entry in config file
% % %         s1{ind_aoa} = ['AOA=' num2str(alfaVec(jj))];
% % %         writelines(s1, "naca0012_JST.cfg");
% % %         % Launch 1st CFD simulation
% % %         system('launchSim.bat')
% % %         % Routine for the 2nd parallelized simulation
% % %         if jj+1<=length(alfaVec)
% % %             s2{ind_aoa} = ['AOA=' num2str(alfaVec(jj+1))];
% % %             writelines(s2, "naca0012_JST2.cfg");
% % %             launchSim2 = "wsl mpirun -n 8 SU2_CFD naca0012_JST2.cfg";
% % %             system(launchSim2)
% % %             % Retrieve Cl, Cd, Mz for the 2nd simulation
% % %             history2 = importCoeffs('history2.csv');
% % %             %  Extracting last row
% % %             lastRow2 = history2(end,:);
% % %             % Computing Cm 
% % %             Cm2 = lastRow2(3)/(0.5*1.225*1*(machVec(ii)*sqrt(1.4*287*288.15))^2);
% % %             % Coefficient saving
% % %             Cd_mat(ii,jj+1) = lastRow2(1);
% % %             Cl_mat(ii,jj+1) = lastRow2(2);
% % %             Cm_mat(ii,jj+1) = Cm2;  
% % %         end
% % %         % Check if the first simulation is finished before importing csv
% % %         % file
% % %         % IMPORTANT: Add OUTPUT_WRT_FREQ = 100000 in config file to avoid
% % %         % vtu creation before the simulation ends.
% % %         flag = 0;
% % %         while true && flag == 0
% % %             if isfile('flow.vtu') 
% % %                 flag = 1;
% % %             end      
% % %         end
% % %         % Retrieve Cl, Cd, Mz for the 1st simulation
% % %         history = importCoeffs('history.csv');  
% % %         %  Extracting last row
% % %         lastRow = history(end,:);        
% % %         % Computing Cm 
% % %         Cm = lastRow(3)/(0.5*1.225*1*(machVec(ii)*sqrt(1.4*287*288.15))^2);        
% % %         % Coefficient saving
% % %         Cd_mat(ii,jj) = lastRow(1);
% % %         Cl_mat(ii,jj) = lastRow(2);
% % %         Cm_mat(ii,jj) = Cm;   
% % %         % Delete simulation files
% % %         delete *.csv
% % %         delete *.dat
% % %         delete *.vtu
% % %     end    
% % % end
%--------------------------------------------------------------------------

% Single running simulation
s = readlines("naca0012_JST.cfg");
ind_aoa = find(strncmp(s, 'AOA', 3));
ind_mach = find(strncmp(s, 'MACH_NUMBER', 11));
Cl_mat = zeros(length(machVec), length(alfaVec));
Cd_mat = zeros(length(machVec), length(alfaVec));
Cm_mat = zeros(length(machVec), length(alfaVec));
for ii = 1:length(machVec)
    iter_m = ii;
    s{ind_mach} = ['MACH_NUMBER=' num2str(machVec(ii))];
    writelines(s, "naca0012_JST.cfg");
    for jj = 1:length(alfaVec)
        iter_a = jj;
        % Update AOA entry in config file
        s{ind_aoa} = ['AOA=' num2str(alfaVec(jj))];
        writelines(s, "naca0012_JST.cfg");
        % Routine for simulation
        launchSimCommandWindow = "wsl mpirun -n 8 SU2_CFD naca0012_JST.cfg &";
        system(launchSimCommandWindow)
        % Check if the first simulation is finished before importing csv
        % IMPORTANT: Add OUTPUT_WRT_FREQ = 100000 in config file to avoid
        % vtu creation before the simulation ends.
        flag = 0;
        while true && flag == 0
            if isfile('flow.vtu') 
                flag = 1;
            end      
        end
        % Retrieve Cl, Cd, Mz
        history = importCoeffs('history.csv');
        %  Extracting last row
        lastRow = history(end,:);
        % Computing Cm 
        Cm = lastRow(3)/(0.5*1.225*1*(machVec(ii)*sqrt(1.4*287*288.15))^2);
        % Coefficient saving
        Cd_mat(ii,jj+1) = lastRow(1);
        Cl_mat(ii,jj+1) = lastRow(2);
        Cm_mat(ii,jj+1) = Cm;  
        delete *.vtu  
    end
% Delete simulation files
delete *.vtu  
end
%--------------------------------------------------------------------------

%% Rotor power evaluation


%end

