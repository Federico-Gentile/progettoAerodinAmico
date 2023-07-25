function [f] = solveRigidRotor(coll, outFlag, inp, data, rotData, aeroData)
%SOLVEROTOR solves rotor induced velocity problem

[~,ind] = min(abs(inp.x-inp.tr));

% Definition of mach at query points [-]
u = sqrt( (rotData.omega*inp.x).^2 + inp.vi.^2 );
mach = u / data.soundSpeed;


% Definition of alpha at query points [deg]
aColl = coll;
aTwis = interp1(rotData.rTw, rotData.Twi, inp.x);
aIndu = atan(inp.vi./u);
alpha = aColl + aTwis + aIndu*180/pi;

mach_root = mach(1:ind);
alpha_root = alpha(1:ind);
mach_tip = mach(ind+1:end);
alpha_tip = alpha(ind+1:end);

% Defining aerodynamic coefficients ad function of mach and AoA [deg]
% mach and alpha are both column vectors of query points
cl = [aeroData{1}.cl(alpha_root,  mach_root)' aeroData{2}.cl(alpha_tip, mach_tip)']';
cd = [aeroData{1}.cd(alpha_root,  mach_root)' aeroData{2}.cd(alpha_tip, mach_tip)']';
L = 0.5 * data.rho * u.^2 .* rotData.c .* cl;
D = 0.5 * data.rho * u.^2 .* rotData.c .* cd;

% Retireving forces in hub reference [N]
Fz = L.*cos(aIndu*pi/180) - D.*sin(aIndu*pi/180);

% Integration along the blade for integral loads [N]
T = 4*trapz(inp.x, Fz);

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
    out.cm = [aeroData{1}.cd(alpha_root,  mach_root)' aeroData{2}.cd(alpha_tip, mach_tip)'];

    out.L = L;
    out.D = D;
    out.M = 0.5 * data.rho * u.^2 .* rotData.c .* out.cm;

    out.Fz = Fz;
    out.Fx = L.*sin(aIndu*pi/180) + D.*cos(aIndu*pi/180);
    out.T = T;
    out.Q = 4*trapz(inp.x, out.Fx.*inp.x); 
    out.P = out.Q * rotData.omega * 0.00134102;
    
end

if outFlag
    f = out;
else
    f = T-rotData.ACw;
end

