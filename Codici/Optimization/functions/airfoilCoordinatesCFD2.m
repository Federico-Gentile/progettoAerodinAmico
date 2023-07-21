
function [data_airfoil] = airfoilCoordinatesCFD2(x, h_mesh)
%x = [((0.4-0.2)*rand+0.2) ((0.9-0.4)*rand+0.4) ((0.247+0.074)*rand-0.074) ((0.206+0.102)*rand-0.102) ((0.4-0.21)*rand+0.21) ((0.25-0.07)*rand+0.07) ((0.9-0.29)*rand+0.29) ((3-0.5)*rand+0.5)];
%h_mesh = 0.002;

% V2.0 - IGP per AIRFOIL NON SIMMETRICI !!!
% NOTE:
% data_airfoil deve contenere 801 coordinate x,y dei punti del profilo
% Le coordinate x,y devono essere ottenute utilizzando la discretizzazione in x del NACA0012 di Caccia
% data_airfoil deve contenere 801 valori di h (dimensione mesh a ciascun punto)
% Parametrizzazione IGP richiede soluzione sistema lineare
% "An improved geometric parameter airfoil parameterizationmethod", Lu Xiaoqiang, Huang Jun, Song Lei, Li Jing (2018)
% x = [c1,c2,c3,c4,XT,T,rho0,betaTE]
% t = [t1,t2,t3,t4,t5]
%--------------------------------------------------------------------------

% Upper and lower limits proposed by the IGP paper authors
%     c1 ∈ [0.010, 0.960] 
%     c2 ∈ [0.020, 0.970] 
%     c3 ∈ [−0.074, 0.247] 
%     c4 ∈ [−0.102, 0.206]
%     XT ∈ [0.2002, 0.4813]
%     T ∈ [0.0246, 0.3227]
%     ρ0_nd ∈ [0.1750, 1.4944]
%     βT_nd E ∈ [0.1452, 4.8724]
% Upper and lower limits proposed by S. Bortolotti thesis
%     c1 ∈ [0.2, 0.4] 
%     c2 ∈ [0.4, 0.9] 
%     XT ∈ [0.21, 0.4]
%     T ∈ [0.07, 0.25]
%     ρ0_nd ∈ [0.29, 0.9]
%     βT_nd E ∈ [0.5, 3]

%--------------------------------------------------------------------------

% Airfoil GRID and MESH SIZE
x_airfoil = readmatrix("x_coordinates_airfoil.txt");
h_airfoil = h_mesh.*(0.2+0.8.*readmatrix("h_coordinates_airfoil.txt"));

% % % Warning for incorrect number of grid points
% % if length(x_airfoil)~=801 || length(h_airfoil)~=801
% %     warning('Le x o h in input ad airfoil_coordinates non sono 801!')
% % end

%% IGP Parametrization
% Thickness distribution is the polynomial reported below
% 5 parameters (t1, t2, t3, t4, t5) being the elements of vector t

% IGP parameters from the design variables vector
c1 = x(1);
c2 = x(2); 
c3 = x(3);
c4 = x(4);
XT = x(5);
T = x(6);
rho0_nd = x(7);
betaTE_nd = x(8);

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
k = linspace(0,1,400);
x_c = 3*c1.*k.*(1-k).^2+3*c2.*(1-k).*(k.^2)+(k.^3);
y_c = 3*c3.*k.*(1-k).^2+3*c4.*(1-k).*(k.^2);

x_u = x_airfoil(1:401);    % x dorso
x_l = x_airfoil(402:801);  % x ventre

y_cu = interp1(x_c,y_c,x_u);
y_cl = interp1(x_c,y_c,x_l);
y_tu = (1/2).*t_igp(x_u);   % y positive (t/2)
y_tl = -(1/2).*t_igp(x_l);  % y negative (t/2)

y_u = y_cu + y_tu;
y_l = y_cl + y_tl;

data_airfoil.x = [x_u;x_l];  
data_airfoil.y = [y_u;y_l];
data_airfoil.h_vect = h_airfoil;

figure()
plot(data_airfoil.x, data_airfoil.y,'ok','MarkerSize',4)
title('IGP parameterization - $X_T$,T,$\rho_0$,$\beta_{TE}$','interpreter','latex')
hold on
xlim([-0.05 1.05])
axis equal