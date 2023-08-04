function rotorPower = fitness(x, sett)

x_root = x(1:4);
x_tip = x(5:8);

%% Meshes Creation (CFD)

% File .geo creation
geoCreationRefBox(x_tip, sett.mesh, sett.mesh.h_fine, "temporaryFiles/Gfine.geo");
geoCreationRefBox(x_tip, sett.mesh, sett.mesh.h_coarse, "temporaryFiles/Gcoarse.geo");

% Mesh creation
meshCommand = "gmsh -format su2 temporaryFiles/Gfine.geo -2 > temporaryFiles/fineMesh.log";
system('start /B wsl ' + meshCommand);
meshCommand = "gmsh -format su2 temporaryFiles/Gcoarse.geo -2 > temporaryFiles/coarseMesh.log";
system('start /B wsl ' + meshCommand);

% %% Blade root coefficients evaluation (XFOIL)
% 
% % Airfoil creation
% airfoilCoordinatesXFOIL(x_root);
% 
% % Airfoil polar computation
% out_xfoil_root = runXFOIL(sett);
% 
% aeroData{1}.cl = out_xfoil_root.Cl;
% aeroData{1}.cd = out_xfoil_root.Cd;
% aeroData{1}.cm = out_xfoil_root.Cm;

flag = 0;
while true && flag == 0
    if isfile('temporaryFiles/Gcoarse.su2') 
        flag = 1;
    end  
end
%% Launch CFD simulation
system('wsl ./shellScripts/main.sh')
end
%% CFD Grid Creation

% [~, ind] = min(abs(inp.x-5));
% nMachCFD = 4;
% indexMachCFD = [ind+1 ceil((linspace((length(inp.x)+ind+1)/2, length(inp.x), nMachCFD-1)))];
% nAlphaCFD = 5;
% machGridCFD = repmat(out.mach(indexMachCFD)', nAlphaCFD, 1);
% alphaGridCFD = repmat(out.alpha(indexMachCFD)', nAlphaCFD, 1) + linspace(-0.5, 2, nAlphaCFD)';
% 
% figure();
% plot(alphaGridCFD, machGridCFD, 'ko', 'DisplayName','GRID')
% hold on;
% plot(out.alpha, out.mach, 'DisplayName','XFOIL')
% plot(max(max(alphaGridCFD)), max(max(machGridCFD)), 'ro', 'DisplayName','RANS POINT')
% xlabel('alpha')
% ylabel('mach')
% legend()
% 
% FF =@(x, y) griddata(reshape(alphaGridCFD,[], 1), reshape(machGridCFD, [], 1),reshape(aeroData{1}.cd(alphaGridCFD, machGridCFD), [], 1), x, y, 'cubic');
% figure();
% [xx, yy] = meshgrid(linspace(out.mach(ind+1), out.mach(end), 100), linspace(min(out.alpha)-1, max(out.alpha)+2, 100));
% %surf(xx, yy, abs(FF(yy, xx)-aeroData{1}.cl(yy, xx))./aeroData{1}.cl(yy, xx));
% surf(xx, yy, abs(FF(yy, xx)));
% 
% hold on
% % surf(xx, yy, aeroData{1}.cl(yy, xx));
% plot3(machGridCFD, alphaGridCFD,aeroData{1}.cd(alphaGridCFD, machGridCFD), 'ro')
% plot3(out.mach(ind+1: end), out.alpha(ind+1: end), aeroData{1}.cd(out.alpha(ind+1:end), out.mach(ind+1: end)), 'LineWidth',3)
% view(2)
% colorbar()
% %% Blade tip coefficients evaluation (CFD)
% % File .geo creation
% % geoCreationRefBox(x)
% % 
% % %% Mesh creation
% % % Writing the wsl commands to generate the mesh
% % meshCommand = "gmsh -format su2 mesh.geo -2";
% % 
% % % Launch WSL and execute the command
% % [status, result] = system('wsl ' + meshCommand);
% % 
% % % Check the status and display the result
% % if status == 0
% %     disp('WSL commands executed successfully.');
% %     disp('Output:');
% %     disp(result);
% % else
% %     disp('Failed to execute WSL commands.');
% %     disp('Error message:');
% %     disp(result);
% % end
% 
% %% Launch CFD simulations
% % Cycle through mach and alfa to create a Cl|Cd vs alpha|Ma table for the
% % current profile
% 
% machVecTip = [0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6];  
% alphaVecTip = 0:0.5:15;
% 
% % Double parallel running simulation
% s1 = readlines("EulerTemplate.cfg");
% s2 = readlines("EulerTemplate2.cfg");
% ind_aoa = find(strncmp(s1, 'AOA', 3));
% ind_mach = find(strncmp(s1, 'MACH_NUMBER', 11));
% ClTip = zeros(length(machVecTip), length(alphaVecTip));
% CdTip = zeros(length(machVecTip), length(alphaVecTip));
% CmTip = zeros(length(machVecTip), length(alphaVecTip));
% for ii = 1:length(machVecTip)
%     iter_m = ii;
%     s1{ind_mach} = ['MACH_NUMBER=' num2str(machVecTip(ii))];
%     s2{ind_mach} = ['MACH_NUMBER=' num2str(machVecTip(ii))];
%     writelines(s1, "EulerTemplate.cfg");
%     writelines(s2, "EulerTemplate2.cfg");
%     for jj = 1:2:length(alphaVecTip)
%         iter_a = jj;
%         % Update AOA entry in config file
%         s1{ind_aoa} = ['AOA=' num2str(alphaVecTip(jj))];
%         writelines(s1, "EulerTemplate.cfg");
%         % Launch 1st CFD simulation
%         system('launchSim.bat')
%         % Routine for the 2nd parallelized simulation
%         if jj+1<=length(alphaVecTip)
%             s2{ind_aoa} = ['AOA=' num2str(alphaVecTip(jj+1))];
%             writelines(s2, "EulerTemplate2.cfg");
%             launchSim2 = "wsl mpirun -n 8 SU2_CFD EulerTemplate2.cfg";
%             system(launchSim2)
%             % Retrieve Cl, Cd, Mz for the 2nd simulation
%             history2 = readmatrix('history2.csv');
%             %  Extracting last row
%             lastRow2 = history2(end,:);
%             % Computing Cm 
%             Cm2 = lastRow2(13)/(0.5*1.225*1*(machVecTip(ii)*sqrt(1.4*287*288.15))^2);
%             % Coefficient saving
%             CdTip(ii,jj+1) = lastRow2(8);
%             ClTip(ii,jj+1) = lastRow2(9);
%             CmTip(ii,jj+1) = Cm2;  
%         end
%         % Check if the first simulation is finished before importing csv
%         % file
%         % IMPORTANT: Add OUTPUT_WRT_FREQ = 100000 in config file to avoid
%         % vtu creation before the simulation ends.
%         flag = 0;
%         while true && flag == 0
%             if isfile('flow.vtu') 
%                 flag = 1;
%             end      
%         end
%         % Retrieve Cl, Cd, Mz for the 1st simulation
%         history = readmatrix('history.csv');  
%         %  Extracting last row
%         lastRow = history(end,:);        
%         % Computing Cm 
%         Cm = lastRow(13)/(0.5*1.225*1*(machVecTip(ii)*sqrt(1.4*287*288.15))^2);        
%         % Coefficient saving
%         CdTip(ii,jj) = lastRow(8);
%         ClTip(ii,jj) = lastRow(9);
%         CmTip(ii,jj) = Cm;   
%         % Delete simulation files
%         delete *.csv
%         delete *.dat
%         delete *.vtu
%     end    
% end
% %--------------------------------------------------------------------------
% 
% %% Rotor power evaluation
% 
% 
% %end
% 
