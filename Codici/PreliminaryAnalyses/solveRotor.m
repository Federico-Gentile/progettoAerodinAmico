function [f, out] = solveRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData)
%SOLVEROTOR solves rotor induced velocity problem

% Definition of mach at query points [-]
u = sqrt( (rotData.omega*inp.x).^2 + vi^2 );
mach = u / ambData.c;

% Definition of alpha at query points [deg]
aColl = currColl;
aTwis = interp1(rotData.rTw, rotData.Twi, inp.x);
aIndu = atan(vi./u);
alpha = aColl + aTwis - aIndu*180/pi;

% Defining aerodynamic coefficients ad function of mach and AoA [deg]
% mach and alpha are both column vectors of query points
cl = diag(interp2(aeroData.mach_cl, aeroData.angle_cl,  aeroData.cl, mach', alpha));
cd = diag(interp2(aeroData.mach_cd, aeroData.angle_cd,  aeroData.cd, mach', alpha));
L = 0.5 * ambData.rho * u.^2 .* rotData.c .* cl;
D = 0.5 * ambData.rho * u.^2 .* rotData.c .* cd;

% Retireving forces in hub reference [N]
Fz = L.*cos(aIndu*pi/180) - D.*sin(aIndu*pi/180);

% Integration along the blade for integral loads [N]
T = 4*trapz(inp.x, Fz);

% Inflow equation to be solved [m/s]
f = sqrt(T/(2*ambData.rho*rotData.Ad)) - vi;

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

    out.L = L;
    out.D = D;

    out.Fz = Fz;
    out.Fx = L.*sin(aIndu*pi/180) + D.*cos(aIndu*pi/180);
    out.T = T;
    out.Q = 4*trapz(inp.x, out.Fx.*inp.x); 
    out.P = out.Q * rotData.omega * 0.00134102;
end

