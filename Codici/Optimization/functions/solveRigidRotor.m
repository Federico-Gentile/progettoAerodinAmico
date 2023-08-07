function [f] = solveRigidRotor(coll, outFlag, sett, aeroData)
%SOLVEROTOR solves rotor induced velocity problem

% Definition of mach at query points [-]
u = sqrt( (sett.rotData.omega*sett.rotSol.x).^2 + sett.rotSol.vi.^2 );
mach = u / sett.ambData.c;

% Definition of alpha at query points [deg]
aColl = coll;
aTwis = interp1(sett.rotData.rTw, sett.rotData.Twi, sett.rotSol.x);
aIndu = atan(sett.rotSol.vi./u)*180/pi;
alpha = aColl + aTwis + aIndu;

mach_root = mach(1:sett.rotSol.ind1);
alpha_root = alpha(1:sett.rotSol.ind1);
mach_tip = mach(sett.rotSol.ind1+1:end);
alpha_tip = alpha(sett.rotSol.ind1+1:end);

% Defining aerodynamic coefficients ad function of mach and AoA [deg]
% mach and alpha are both column vectors of query points
cl = [aeroData{1}.cl(mach_root, alpha_root)' aeroData{2}.cl(mach_tip, alpha_tip)']';
cd = [aeroData{1}.cd(mach_root, alpha_root)' aeroData{2}.cd(mach_tip, alpha_tip)']';
cm = [aeroData{1}.cm(mach_root, alpha_root)' aeroData{2}.cm(mach_tip, alpha_tip)']';

L = 0.5 * sett.ambData.rho * u.^2 .* sett.rotData.c .* cl;
D = 0.5 * sett.ambData.rho * u.^2 .* sett.rotData.c .* cd;

% Retireving forces in hub reference [N]
Fz = L.*cos(-aIndu*pi/180) - D.*sin(-aIndu*pi/180);

% Integration along the blade for integral loads [N]
T = 4*trapz(sett.rotSol.x, Fz);

% Collecting outputs
if outFlag
    out.u = u;
    out.mach = mach;
    out.aColl = aColl;
    out.aTwis = aTwis;
    out.aIndu = aIndu;
    out.alpha = alpha;

    out.cl = cl;
    out.cd = cd;
    out.cm = cm;
    out.L = L;
    out.D = D;
    out.M = 0.5 * sett.ambData.rho * u.^2 .* sett.rotData.c .* out.cm;
    out.Fz = Fz;
    out.Fx = L.*sin(-aIndu*pi/180) + D.*cos(-aIndu*pi/180);
    out.T = T;
    out.Q = 4*trapz(sett.rotSol.x, out.Fx.*sett.rotSol.x); 
    out.P = out.Q * sett.rotData.omega * 0.00134102;
    
end

if outFlag
    f = out;
else
    f = T-sett.rotData.ACw;
end

