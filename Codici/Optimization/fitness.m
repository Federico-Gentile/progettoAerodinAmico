% function rotorPower = fitness(x)
clc
clear 
delete *.csv
delete *.dat
delete *.vtu
delete *.geo
% delete *.su2
delete polar.txt


addpath(genpath("configFiles"))
addpath(genpath("coordinates"))
addpath(genpath("functions"))
addpath(genpath("XFOIL"))
%% Data
rho     = 1.225;
chord   = 0.537;
soundSpeed = 340;
mu      = 1.8*1e-5;
gamma   = 1.4; 
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
 airfoilCoordinatesXFOIL(x);

% %%
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
fprintf(fid, 'vpar\n');
% fprintf(fid, 'xtr\n');
% fprintf(fid, '0.05\n');
% fprintf(fid, '0.05\n\n');
fprintf(fid, 'N 3\n\n');
 machVecRoot = [0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6];
alphaVecRoot = 0:0.5:10;
ClRoot = zeros(length(machVecRoot), length(alphaVecRoot));
CdRoot = zeros(length(machVecRoot), length(alphaVecRoot));
CmRoot = zeros(length(machVecRoot), length(alphaVecRoot));
nConv  = zeros(length(machVecRoot), 1);   % Keep track of polar correction for each Mach number
[XX, YY] = meshgrid(alphaVecRoot, machVecRoot);
Y = [];
X = [];
V_cl = [];
V_cd = [];
V_cm = [];
V_cpmin = [];

for ii = 1:length(machVecRoot)
    Re = rho * chord * machVecRoot(ii) * soundSpeed / mu;
    if ii == 1
        fprintf(fid, "re " + num2str(Re) + "\n");
        fprintf(fid, "mach " + num2str(machVecRoot(ii)) + "\n");
        fprintf(fid, 'a 0\n');
        fprintf(fid,'pacc\n');
        fprintf(fid,'polar.txt\n\n');
        fprintf(fid,'cinc\n');
        fprintf(fid,'aseq 0 10 0.5\n');
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
    nConv(ii) = length(polar(:, 1));
    X = [X; polar(:, 1)]; 
    Y = [Y; machVecRoot(ii)*ones(nConv(ii), 1)];
    V_cl = [V_cl; polar(:, 2)];
    V_cd = [V_cd; polar(:, 3)];
    V_cm = [V_cm; polar(:, 5)];
    V_cpmin = [V_cpmin; polar(:, 6)]; 
    % Delete current polar.txt
    delete polar.txt    
end
F_cl = scatteredInterpolant(X, Y, V_cl, 'natural');
Cl_root = F_cl(XX, YY);
F_cd = scatteredInterpolant(X, Y, V_cd, 'natural');
Cd_root = F_cd(XX, YY);
F_cm = scatteredInterpolant(X, Y, V_cm, 'natural');
Cm_root = F_cm(XX, YY);
F_cpmin = scatteredInterpolant(X, Y, V_cpmin, 'natural');
Cpmin_root = F_cpmin(XX, YY);
Cpsonic = @(Ma) 2 * ( ( 2/(gamma+1))^(gamma/(gamma-1) ) * (1 + (gamma-1)/2*Ma.^2).^(gamma/(gamma-1)) - 1 )./ (gamma*Ma.^2);
criticalMat = Cpmin_root < Cpsonic(YY);
figure
surf(XX,YY,double(criticalMat))
%% Blade tip coefficients evaluation (CFD)
% File .geo creation
% geoCreationRefBox(x)
% 
% %% Mesh creation
% % Writing the wsl commands to generate the mesh
% meshCommand = "gmsh -format su2 mesh.geo -2";
% 
% % Launch WSL and execute the command
% [status, result] = system('wsl ' + meshCommand);
% 
% % Check the status and display the result
% if status == 0
%     disp('WSL commands executed successfully.');
%     disp('Output:');
%     disp(result);
% else
%     disp('Failed to execute WSL commands.');
%     disp('Error message:');
%     disp(result);
% end

%% Launch CFD simulations
% Cycle through mach and alfa to create a Cl|Cd vs alpha|Ma table for the
% current profile

machVecTip = [0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6];  
alphaVecTip = 0:0.5:15;

% Double parallel running simulation
s1 = readlines("EulerTemplate.cfg");
s2 = readlines("EulerTemplate2.cfg");
ind_aoa = find(strncmp(s1, 'AOA', 3));
ind_mach = find(strncmp(s1, 'MACH_NUMBER', 11));
ClTip = zeros(length(machVecTip), length(alphaVecTip));
CdTip = zeros(length(machVecTip), length(alphaVecTip));
CmTip = zeros(length(machVecTip), length(alphaVecTip));
for ii = 1:length(machVecTip)
    iter_m = ii;
    s1{ind_mach} = ['MACH_NUMBER=' num2str(machVecTip(ii))];
    s2{ind_mach} = ['MACH_NUMBER=' num2str(machVecTip(ii))];
    writelines(s1, "EulerTemplate.cfg");
    writelines(s2, "EulerTemplate2.cfg");
    for jj = 1:2:length(alphaVecTip)
        iter_a = jj;
        % Update AOA entry in config file
        s1{ind_aoa} = ['AOA=' num2str(alphaVecTip(jj))];
        writelines(s1, "EulerTemplate.cfg");
        % Launch 1st CFD simulation
        system('launchSim.bat')
        % Routine for the 2nd parallelized simulation
        if jj+1<=length(alphaVecTip)
            s2{ind_aoa} = ['AOA=' num2str(alphaVecTip(jj+1))];
            writelines(s2, "EulerTemplate2.cfg");
            launchSim2 = "wsl mpirun -n 8 SU2_CFD EulerTemplate2.cfg";
            system(launchSim2)
            % Retrieve Cl, Cd, Mz for the 2nd simulation
            history2 = readmatrix('history2.csv');
            %  Extracting last row
            lastRow2 = history2(end,:);
            % Computing Cm 
            Cm2 = lastRow2(13)/(0.5*1.225*1*(machVecTip(ii)*sqrt(1.4*287*288.15))^2);
            % Coefficient saving
            CdTip(ii,jj+1) = lastRow2(8);
            ClTip(ii,jj+1) = lastRow2(9);
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
        history = readmatrix('history.csv');  
        %  Extracting last row
        lastRow = history(end,:);        
        % Computing Cm 
        Cm = lastRow(13)/(0.5*1.225*1*(machVecTip(ii)*sqrt(1.4*287*288.15))^2);        
        % Coefficient saving
        CdTip(ii,jj) = lastRow(8);
        ClTip(ii,jj) = lastRow(9);
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

