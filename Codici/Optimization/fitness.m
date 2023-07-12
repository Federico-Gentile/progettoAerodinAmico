% function rotorPower = fitness(x)
clc
clear 
close
delete *.csv
delete *.dat
delete *.vtu
delete *.geo
delete *.su2
delete *.txt


addpath("configFiles")
addpath("coordinates")
addpath("functions")
addpath("XFOIL")
%% Data
rho     = 1.225;
chord   = 0.537;
soundSpeed = 340;
mu      = 1.8*1e-5;
%% Testing   x = [XT,T,rho0,betaTE]
% Upper and lower limits proposed by S. Bortolotti thesis
% % % XT ∈ [0.21, 0.4]
% % % T ∈ [0.07, 0.25]
% % % ρ0_nd ∈ [0.29, 0.9]
% % % βT_nd E ∈ [0.5, 3]
% x = [0.21 0.25 0.290  3]; % profilo ape maia per test codice
% x = [0.21 0.25 0.290 0.5]; % profilo goccia 1
% x = [0.4 0.25 0.290 0.5]; % profilo goccia 2
x = [0.3 0.12 0.4322 2.022];  % simile al NACA0012

% % % % %% Blade root coefficients evaluation (XFOIL)
% Airfoil creation
airfoilCoordinatesXFOIL(x)

%%
fid = fopen('xfoil_input.txt','w');
fprintf(fid, 'load rootAirfoil.txt\n');
fprintf(fid, 'pane\n');
fprintf(fid, 'ppar\n');
fprintf(fid, 'N 200\n\n\n');
fprintf(fid, 'gdes\n');
fprintf(fid, 'tgap\n');
fprintf(fid, '0.01\n');
fprintf(fid, '0.3\n\n');
fprintf(fid, 'pane\n');
fprintf(fid, 'ppar\n');
fprintf(fid, 'N 210\n\n\n');    
fprintf(fid, 'oper\n');
fprintf(fid, 'visc on\n');
fprintf(fid, '6e6\n');
fprintf(fid,'iter 200\n');
machVecRoot = [0.1 0.2 0.3 0.4 0.5];
alphaVecRoot = 2:0.5:20;
ClRoot = zeros(length(machVecRoot), length(alphaVecRoot));
CdRoot = zeros(length(machVecRoot), length(alphaVecRoot));
CmRoot = zeros(length(machVecRoot), length(alphaVecRoot));
ncorr  = zeros(length(machVecRoot), 1);   % Keep track of polar correction for each Mach number
for ii = 1:length(machVecRoot)
    Re = rho * chord * machVecRoot(ii) * soundSpeed / mu;
    if ii == 1
        fprintf(fid, "re " + num2str(Re) + "\n");
        fprintf(fid, "mach " + num2str(machVecRoot(ii)) + "\n");
        fprintf(fid, 'a 0\n');
        fprintf(fid,'pacc\n');
        fprintf(fid,'polar.txt\n\n');
        fprintf(fid,'aseq 2 20 0.5\n');
        s_xfoil  = readlines('xfoil_input.txt');
        ind_re   = find(strncmp(s_xfoil, 're', 2));
        ind_mach = find(strncmp(s_xfoil, 'mach', 4)); 
        
    else
        s_xfoil{ind_re} = ['re ' num2str(Re)];
        s_xfoil{ind_mach} = ['mach ' num2str(machVecRoot(ii))];
        writelines(s_xfoil, "xfoil_input.txt")
    end    
    system('.\XFOIL\xfoil.exe < xfoil_input.txt; exit')
    % Extract data from polar.txt
    polar = readmatrix('polar.txt');
    % Check if the XFOIL reached convergence for every tested AOA
    % AT THE MOMENT THIS PIECE OF CODE DOES NOT WORK IF THERE ARE 2
    % CONSECUTIVE NOT CONVERGED ANGLES.
    if size(polar,1) ~= length(alphaVecRoot)
        % Creating the corrected polar, which filles the non converged rows
        % of the polar with a in interpolation of the neighbours values
        polar_corrected = zeros(length(alphaVecRoot),size(polar,2));
        % For loop to find the non converged cases
        for kk = 1:length(alphaVecRoot)
            % Particular case: update of the number of corrections when the
            % last angle did not converged
            if kk == length(alphaVecRoot) && ncorr(ii) ~= (length(alphaVecRoot) - size(polar, 1))
                ncorr(ii) = ncorr(ii) + 1;
            end
            % If the non converged angle is found
            if polar(kk-ncorr(ii),1) ~= alphaVecRoot(kk)
                % The angle of polar corrected is set to the right one.
                polar_corrected(kk, 1) = alphaVecRoot(kk);
                % Particular case: the first angle did not converge
                if kk == 1
                     % We put the value of the successive angle
                     polar_corrected(kk, 2:end) = polar(kk,2:end);  
                % Particular case: the last angle di not converge
                elseif kk == length(alphaVecRoot)
                     % We put the value of the second to last angle
                     polar_corrected(kk, 2:end) = polar(kk-ncorr(ii),2:end); 
                else
                     % Every other case
                     polar_corrected(kk, 2:end) = (polar(kk-ncorr(ii),2:end) + polar(kk-1-ncorr(ii),2:end))/2;
                end
                % If you are not at the last angle update the number of
                % correction
                if kk ~= length(alphaVecRoot)
                     ncorr(ii) = ncorr(ii) + 1;
                end
            else
                % If the current angle is converged, simply copy the polar
                % value
                polar_corrected(kk, :) = polar(kk-ncorr(ii),:);
            end
            
        end
        ClRoot(ii,:) = polar_corrected(:,2)';
        CdRoot(ii,:) = polar_corrected(:,3)';
        CmRoot(ii,:) = polar_corrected(:,5)';
    else
        ClRoot(ii,:) = polar(:,2)';
        CdRoot(ii,:) = polar(:,3)';
        CmRoot(ii,:) = polar(:,5)';
    end
    % Delete current polar.txt
    delete polar.txt    
end

%% Blade tip coefficients evaluation (CFD)
% File .geo creation
geoCreationRefBox(x)

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

machVecTip = [0.52 0.55 0.58 0.61 0.64];  
alphaVecTip = [4 6 8 10];

% Double parallel running simulation
s1 = readlines("naca0012_JST.cfg");
s2 = readlines("naca0012_JST2.cfg");
ind_aoa = find(strncmp(s1, 'AOA', 3));
ind_mach = find(strncmp(s1, 'MACH_NUMBER', 11));
ClTip = zeros(length(machVecTip), length(alphaVecTip));
CdTip = zeros(length(machVecTip), length(alphaVecTip));
CmTip = zeros(length(machVecTip), length(alphaVecTip));
for ii = 1:length(machVecTip)
    iter_m = ii;
    s1{ind_mach} = ['MACH_NUMBER=' num2str(machVecTip(ii))];
    s2{ind_mach} = ['MACH_NUMBER=' num2str(machVecTip(ii))];
    writelines(s1, "configFiles/naca0012_JST.cfg");
    writelines(s2, "configFiles/naca0012_JST2.cfg");
    for jj = 1:2:length(alphaVecTip)
        iter_a = jj;
        % Update AOA entry in config file
        s1{ind_aoa} = ['AOA=' num2str(alphaVecTip(jj))];
        writelines(s1, "configFiles/naca0012_JST.cfg");
        % Launch 1st CFD simulation
        system('launchSim.bat')
        % Routine for the 2nd parallelized simulation
        if jj+1<=length(alphaVecTip)
            s2{ind_aoa} = ['AOA=' num2str(alphaVecTip(jj+1))];
            writelines(s2, "configFiles/naca0012_JST2.cfg");
            launchSim2 = "wsl mpirun -n 8 SU2_CFD naca0012_JST2.cfg";
            system(launchSim2)
            % Retrieve Cl, Cd, Mz for the 2nd simulation
            history2 = readmatrix('history2.csv');
            %  Extracting last row
            lastRow2 = history2(end,:);
            % Computing Cm 
            Cm2 = lastRow2(3)/(0.5*1.225*1*(machVecTip(ii)*sqrt(1.4*287*288.15))^2);
            % Coefficient saving
            CdTip(ii,jj+1) = lastRow2(1);
            ClTip(ii,jj+1) = lastRow2(2);
            CmTip(ii,jj+1) = Cm2;  
        end
        % Check if the first simulation is finished before importing csv
        % file
        % IMPORTANT: Add OUTPUT_WRT_FREQ = 100000 in config file to avoid
        % vtu creation before the simulation ends.
        flag = 0;
        while true && flag == 0
            if isfile('flow.vtu') 
                flag = 1;
            end      
        end
        % Retrieve Cl, Cd, Mz for the 1st simulation
        history = importCoeffs('history.csv');  
        %  Extracting last row
        lastRow = history(end,:);        
        % Computing Cm 
        Cm = lastRow(3)/(0.5*1.225*1*(machVecTip(ii)*sqrt(1.4*287*288.15))^2);        
        % Coefficient saving
        CdTip(ii,jj) = lastRow(1);
        ClTip(ii,jj) = lastRow(2);
        CmTip(ii,jj) = Cm;   
        % Delete simulation files
        delete *.csv
        delete *.dat
        delete *.vtu
    end    
end
%--------------------------------------------------------------------------

%% Rotor power evaluation


%end

