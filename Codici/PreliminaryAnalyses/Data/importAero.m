
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
else
    load(inp.aeroDataset);  
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
    
end

% Creating interpolants
aeroData.Fcl = griddedInterpolant(aeroData.mach_cl', aeroData.angle_cl', aeroData.cl', 'spline');
aeroData.Fcd = griddedInterpolant(aeroData.mach_cd', aeroData.angle_cd', aeroData.cd', 'spline');
aeroData.Fcm = griddedInterpolant(aeroData.mach_cm', aeroData.angle_cm', aeroData.cm', 'spline');

if min(inp.uniformInflow) == 0
    load('inflow.mat');
    inflow.coll = [12 14 15 16 17]';
    inflow.Wac = Wac;
    inflow.bladeStations = bladeStations;
    inflow.vi = -vi;

    % Building inflow distribution interpolant as function of collective
    [inflow.collGRID, inflow.bladeStationsGRID] = ndgrid(inflow.coll, inflow.bladeStations);
    inflow.Finflow = griddedInterpolant(inflow.collGRID, inflow.bladeStationsGRID, inflow.vi);

    % Building inflow distribution interpolant as function of collective
    [inflow.wacGRID, inflow.bladeStationsGRID] = ndgrid(inflow.Wac, inflow.bladeStations);
    inflow.FinflowWac = griddedInterpolant(inflow.wacGRID, inflow.bladeStationsGRID, inflow.vi);

    clearvars bladeStations vi Wac
end
