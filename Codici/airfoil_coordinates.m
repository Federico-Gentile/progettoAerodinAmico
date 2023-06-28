
function [data_airfoil] = airfoil_coordinates(x, h_mesh)

% NOTE:
% data_airfoil deve contenere 801 coordinate x,y dei punti del profilo
% Le coordinate x,y devono essere ottenute utilizzando la discretizzazione in x del NACA0012 di Caccia
% data_airfoil deve contenere 801 valori di h (dimensione mesh a ciascun punto)
% Parametrizzazione IGP richiede soluzione sistema lineare
% "An improved geometric parameter airfoil parameterizationmethod", Lu Xiaoqiang, Huang Jun, Song Lei, Li Jing (2018)
% p = [XT,T,rho0,betaTE]
% t = [t1,t2,t3,t4,t5]
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%% TEST CASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % close all
% % % clear all
% % % clc
% % % x_airfoil = readmatrix("x_coordinates_airfoil.txt")';
% % % h_airfoil = 0.005.*readmatrix("h_coordinates_airfoil.txt")';
% % % XT = 0.4;
% % % T = 0.07;
% % % rho0_nd = 0.29;
% % % betaTE_nd = 3;
%--------------------------------------------------------------------------

% Upper and lower limits proposed by the IGP paper authors
% % % XT ∈ [0.2002, 0.4813]
% % % T ∈ [0.0246, 0.3227]
% % % ρ0_nd ∈ [0.1750, 1.4944]
% % % βT_nd E ∈ [0.1452, 4.8724]
% Upper and lower limits proposed by S. Bortolotti thesis
% % % XT ∈ [0.21, 0.4]
% % % T ∈ [0.07, 0.25]
% % % ρ0_nd ∈ [0.29, 0.9]
% % % βT_nd E ∈ [0.5, 3]
%--------------------------------------------------------------------------

% Airfoil GRID and MESH SIZE
x_airfoil = readmatrix("coordinates/x_coordinates_airfoil.txt");
h_airfoil = h_mesh.*readmatrix("coordinates/h_coordinates_airfoil.txt");

% % % Warning for incorrect number of grid points
% % if length(x_airfoil)~=801 || length(h_airfoil)~=801
% %     warning('Le x o h in input ad airfoil_coordinates non sono 801!')
% % end

%% IGP Parametrization
% Thickness distribution is the polynomial reported below
% 5 parameters (t1, t2, t3, t4, t5) being the elements of vector t

% IGP parameters from the design variables vector
XT = x(1);
T = x(2);
rho0_nd = x(3);
betaTE_nd = x(4);

% Dimensional rho and beta from the non-dimensional values
rho0 = rho0_nd*(T/XT)^2;
betaTE = betaTE_nd*atan(T/(1-XT));
betaTE_deg = rad2deg(betaTE);

% Linear system solution to define the IGP polynomial coefficients
b = [T 0 -tan(betaTE./2) sqrt(2*rho0) 0]';
A = [XT.^0.5  XT  XT.^2  XT.^3  XT.^4
     0.5*(XT.^(-0.5)) 1  2*XT  3*(XT.^2)  4*(XT.^3)
     0.25 0.5 1 1.5 2
     1 0 0 0 0
     1 1 1 1 1];
t = A\b;

% Thickness distribution IGP polynomial
t_igp = @(x) t(1).*(x.^0.5) + t(2).*(x) + t(3).*(x.^2) + t(4).*(x.^3) + t(5).*(x.^4);

% Airfoil coordinates
x_u = x_airfoil(1:401);    % x dorso
x_l = x_airfoil(402:801);  % x ventre

y_u = (1/2).*t_igp(x_u);   % y positive (t/2)
y_l = -(1/2).*t_igp(x_l);  % y negative (t/2)

data_airfoil.x = [x_u;x_l];  
data_airfoil.y = [y_u;y_l];
data_airfoil.h = h_airfoil;

% % % figure()
% % % plot(data_airfoil.x, data_airfoil.y,'ok','MarkerSize',4)
% % % title('IGP parameterization - $X_T$,T,$\rho_0$,$\beta_{TE}$','interpreter','latex')
% % % hold on
% % % xlim([-0.05 1.05])
% % % axis equal