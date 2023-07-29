
addpath('Data/AerodynamicDatabase/');

if strcmp(inp.aeroDataset,'naca0012_CFD.mat')
    load('naca0012_CFD.mat');   
    aeroData.angle_cd = ANGLE_Cd;
    aeroData.angle_cl = ANGLE_Cl;
    aeroData.angle_cm = ANGLE_Cm(:,1:end-1); 
    aeroData.cd = Cd;
    aeroData.cl = Cl;
    aeroData.cm = Cm(:,1:end-1);
    aeroData.mach_cd = MACH_Cd;
    aeroData.mach_cl = MACH_Cl;
    aeroData.mach_cm = MACH_Cm(:,1:end-1);
    clearvars ANGLE_Cd ANGLE_Cl ANGLE_Cm Cd Cl Cm MACH_Cd MACH_Cm MACH_Cl
elseif strcmp(inp.aeroDataset,'naca0012_RANS.mat')
    load('naca0012_RANS.mat');   
    aeroData.angle_cd = ANGLE_Cd;
    aeroData.angle_cl = ANGLE_Cl;
    aeroData.angle_cm = ANGLE_Cm; 
    aeroData.cd = Cd;
    aeroData.cl = Cl;
    aeroData.cm = Cm;
    aeroData.mach_cd = MACH_Cd;
    aeroData.mach_cl = MACH_Cl;
    aeroData.mach_cm = MACH_Cm;
    clearvars ANGLE_Cd ANGLE_Cl ANGLE_Cm Cd Cl Cm MACH_Cd MACH_Cm MACH_Cl
else
    error('Requested Aerodynamic Dataset Does Not Exist!');
end

if inp.momentumTheory == 0
    load(inp.inflowDataset);
    inflow.Wac = Wac;
    inflow.bladeStations = bladeStations;
    inflow.vi = -vi;
    clearvars bladeStations vi Wac
end
