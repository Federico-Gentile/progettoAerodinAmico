%--------------------------------------------------------------------------
clear %--------------------------------------------------------------------
close %--------------------------------------------------------------------
clc %----------------------------------------------------------------------
%--------------------------------------------------------------------------


%% XV-15 uniform inflow estimation code
% Options ----------------------------------------------------------------
%radial_station = [1 2 3 4 5 6 7 8 9 10 11 12];                             % airfoil radial station(s) (1,2, ... ,12)
radial_station = 8;
T = 200;                                                                    % [N]
coll = 10;                                                                  % [deg] collective angle
rpm = 1800;                                                                 % rotor RPM

% Data (from Betzina (1997)) ---------------------------------------------
beta_distr = [26.7000 23.2000 17.8000 11.1000 8.2000 3.8000 2.2000 0 -0.8000 -2.6000 -3.9000 -4.6000];
rR_distr = [0.1550 0.2060 0.3060 0.4050 0.5060 0.6060 0.7070 0.7560 0.8050 0.8560 0.9060 0.9590];
c_distr = [4.0900 4.0500 4.0200 3.9000 3.7700 3.6000 3.3900 3.2500 3.0900 2.9500 2.7800 2.5400];
c_distr = 0.0254.*c_distr;           % INCHES to METERS!
rR = rR_distr(radial_station);       % [-] r/R station of the airfoil 
beta = beta_distr(radial_station);   % [deg] twist of THAT airfoil section
c = c_distr(radial_station);         % [m] chord of THAT airfoil section
rho = 1.225;            % air dynamic viscosity
mu = 1.8e-05;           % air density
R = 0.6096;             % blade radius
omega = rpm*2*pi./60;   % [rad/s] rotor angular speed

% Inflow velocity and angle estimation, mach, Reynolds -------------------
CT = T./(rho*pi.*(R.^2).*(R.*omega).^2);  % thrust coefficient
lambdai = sqrt(CT./2);                    % inflow coefficient
vi = lambdai.*omega.*R;      % [m/s] inflow velocity
vh = omega.*rR.*R;           % [m/s] horizontal velocity of blade section
ai = rad2deg(atan(vi./vh));  % [deg] (negative) angle induced by inflow
aeff = coll + beta - ai;     % [deg] effective angle of that blade section
u = sqrt(vi.^2+vh.^2);       % [m/s] overall velocity of that blade section
m = u/340;                   % [-] mach number of the section
re = (rho.*u.*c)./mu;        % [-] Reynolds number of the section

%% V22 - Osprey
R_22 = 11.6/2;   % [m] rotor diameter
rpm_22 = 412;    % RPM in helicopter mode (data found on web)
omega_22 = rpm_22*2*pi./60;
vtip_22 = omega_22*R_22;
mtip_22 = vtip_22/340;


