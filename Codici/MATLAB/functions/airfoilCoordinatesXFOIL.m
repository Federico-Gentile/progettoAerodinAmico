
function [] = airfoilCoordinatesXFOIL(y)
% NOTE:
% y in INPUT deve essere il vettore di 4 parametri per profilo IGP simmetrico
% Il codice produce un profilo con sharp TE. Quest'ultimo può eventualmente essere rimaneggiato direttamente all'interno di XFOIL
% data_airfoil deve contenere 200 coordinate x,y dei punti del profilo, destinate a XFOIL, prese dal file x_coordinates_xfoil
% Parametrizzazione IGP richiede soluzione sistema lineare
% "An improved geometric parameter airfoil parameterizationmethod", Lu Xiaoqiang, Huang Jun, Song Lei, Li Jing (2018)
% x = [XT,T,rho0,betaTE]
% t = [t1,t2,t3,t4,t5]
%--------------------------------------------------------------------------

%% FOR TESTING ONLY   y = [XT,T,rho0,betaTE]
% Upper and lower limits proposed by S. Bortolotti thesis
% % % XT ∈ [0.21, 0.4]
% % % T ∈ [0.07, 0.25]
% % % ρ0_nd ∈ [0.29, 0.9]
% % % βT_nd E ∈ [0.5, 3]
% y = [0.21 0.25 0.290  3]; % profilo ape maia per test codice
% y = [0.21 0.25 0.290 0.5]; % profilo goccia 1
% y = [0.4 0.25 0.290 0.5]; % profilo goccia 2
% y = [0.3 0.12 0.4322 2.022];  % simile al NACA0012
%--------------------------------------------------------------------------

% Airfoil GRID and MESH SIZE
x_coordinates_xfoil = readmatrix("coordinates/x_coordinates_xfoil.txt");
%--------------------------------------------------------------------------

%% IGP Parametrization
% Thickness distribution is the polynomial reported below
% 5 parameters (t1, t2, t3, t4, t5) being the elements of vector t
% IGP parameters from the design variables vector:
XT = y(1);
T = y(2);
rho0_nd = y(3);
betaTE_nd = y(4);
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
x_u = x_coordinates_xfoil(1:100);    % x dorso
x_l = x_coordinates_xfoil(101:200);  % x ventre
y_u = (1/2).*t_igp(x_u);             % y positive (t/2)
y_l = -(1/2).*t_igp(x_l);            % y negative (t/2)
%--------------------------------------------------------------------------

%% Airfoil points
x_coordinates = [x_u;x_l];  
y_coordinates = [y_u;y_l];
A = zeros(1+length(x_coordinates), 2);  %  --> first row is empty to leave space to  the
for ii=2:(1+length(x_coordinates))      %  --> airfoil name into the airfoil .txt file
   A(ii,1)=x_coordinates(ii-1);   
   A(ii,2)=y_coordinates(ii-1);         
end
%--------------------------------------------------------------------------

%% Printing to .txt
fileID = fopen('rootAirfoil.txt','w');
fprintf(fileID,'rootAirfoil\n');
% Scrittura delle coordinate dalla seconda riga in poi
for ii=2:size(A,1)
fprintf(fileID,'%d %d\n',A(ii,:));
end
%--------------------------------------------------------------------------

% figure()
% plot(data_airfoil.x, data_airfoil.y,'ok','MarkerSize',4)
% title('IGP parameterization - $X_T$,T,$\rho_0$,$\beta_{TE}$','interpreter','latex')
% hold on
% xlim([-0.05 1.05])
% axis equal