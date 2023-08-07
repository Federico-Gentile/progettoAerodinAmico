
% Std air data
ambData.mu = 1.79E-05;  %Dynamic viscosity Pa s
ambData.p = 101325;     %Pressure Pa
ambData.rho = 1.225;    %Density kg/m^3
ambData.R = 8.314462;   %R Universal gas constant j/mol K
ambData.MW = 0.02897;   %Molar mass mol/kg
ambData.Rst = ambData.R/ambData.MW; %Air gas constant j/kg K
ambData.gamma = 1.4;    %Heat ratio
ambData.T = ambData.p/(ambData.Rst*ambData.rho);    %Temperature K
ambData.c = sqrt(ambData.gamma*ambData.Rst*ambData.T); %Sound speed m/s


