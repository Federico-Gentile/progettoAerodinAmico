function [f, out] = solveElasticRotor(vi, outFlag, currColl, inp, ambData, rotData, aeroData, structure, uniformInflow)
%SOLVEELASTICROTOR solves rotor induced velocity problem

% Definition of mach at query points [-]
u = sqrt( (rotData.omega*inp.x).^2 + vi.^2 );
mach = u / ambData.c;

% Definition of alpha at query points [deg] ( w blade deformation contribution)
aColl = currColl;
aTwis = interp1(rotData.rTw, rotData.Twi, inp.x);
aIndu = atan(vi./u)*180/pi;

ftosolve = @(q) elasticRotorDeformation(q, u, mach, aColl, aTwis, aIndu, rotData, inp, aeroData, structure, ambData);
[qOut,~,exitFlag] = fsolve(ftosolve, inp.q0, inp.options);
aThet = structure.ModesgtInterpolated' * qOut * 180/pi;

alpha = aColl + aTwis + aThet - aIndu;

% Defining aerodynamic coefficients ad function of mach and AoA [deg]
% mach and alpha are both column vectors of query points
[machq, alphaq] = meshgrid(mach, alpha);
cl = diag(aeroData.Fcl(machq', alphaq'));
cd = diag(aeroData.Fcd(machq', alphaq'));
L = 0.5 * ambData.rho * u.^2 .* rotData.c .* cl;
D = 0.5 * ambData.rho * u.^2 .* rotData.c .* cd;

% Retireving forces in hub reference [N]
Fz = L.*cos(aIndu*pi/180) - D.*sin(aIndu*pi/180);

% Integration along the blade for integral loads [N]
T = 4*trapz(inp.x, Fz);

% Inflow equation to be solved [m/s]
if uniformInflow
    f = sqrt(T/(2*ambData.rho*rotData.Ad)) - vi;
else
    f = 0;
end

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
    out.cm = diag(interp2(aeroData.mach_cm, aeroData.angle_cm,  aeroData.cm, mach', alpha));

    out.L = L;
    out.D = D;
    out.M = 0.5 * ambData.rho * u.^2 .* rotData.c .* out.cm;

    out.Fz = Fz;
    out.Fx = L.*sin(aIndu*pi/180) + D.*cos(aIndu*pi/180);
    out.T = T;
    out.Q = 4*trapz(inp.x, out.Fx.*inp.x); 
    out.P = out.Q * rotData.omega * 0.00134102;
end

end

