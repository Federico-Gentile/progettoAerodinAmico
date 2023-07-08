%function [] = geoCreationRefBox(x,h,R,BL)
% NOTE:
% iter contiene i_cycle (iterata del ciclo di ottimizzazione) e i_part (indice della particella)
% data_airfoil deve contenere 801 coordinate x,y dei punti del profilo
% Le coordinate x,y devono essere ottenute utilizzando la discretizzazione in x del NACA0012 di Caccia
% data_airfoil deve contenere 801 valori di h (dimensione mesh a ciascun punto)
% Il vettore h deve essere già nella sua forma finale, ovvero il prodotto
% fra il vettore h_size del NACA0012 di Caccia e una misura di riferimento (ad esempio 0.01 o 0.005)
%--------------------------------------------------------------------------

%% FOR TESTING ONLY
    h = 0.0025;
    % 10 15 20 25 30 35
    R = 40;
    BL = 1;
    % x = [XT,T,rho0,betaTE]
    % Upper and lower limits proposed by S. Bortolotti thesis
    % % % XT ∈ [0.21, 0.4]
    % % % T ∈ [0.07, 0.25]
    % % % ρ0_nd ∈ [0.29, 0.9]
    % % % βT_nd E ∈ [0.5, 3]
    % x = [0.21 0.25 0.290  3]; % profilo ape maia per test codice
    % x = [0.21 0.25 0.290 0.5]; % profilo goccia 1
    % x = [0.4 0.25 0.290 0.5]; % profilo goccia 2
    x = [0.3 0.12 0.4322 2.022];  % simile al NACA0012
    XT = x(1);
    T = x(2);
    rho0_nd = x(3);
    betaTE_nd = x(4);
    betaTE = betaTE_nd*atan(T/(1-XT));
    betaTE_deg = rad2deg(betaTE);
%--------------------------------------------------------------------------

%% OPTIONS
% 1. Boundary Layer Flag (Euler vs RANS)
    % BL=1 --> YES
    % BL=0 --> NO
    % First cell size -> may need TUNING according to Y+
    ss = 0.000003;        % baseline s = 0.000004
%--------------------------------------------------------------------------

% 2. Domain independence <-> Grid independence
    % 1 = Domain independence
    % 2 = Grid independence
    II = 1;
%--------------------------------------------------------------------------

% 3. Fixed h <-> Variable h (Caccia distribution)
    % 1 = Fixed
    % 2 = Variable
    hh = 2;
%--------------------------------------------------------------------------

% 4. TE fan number of elements
    % Baseline is 40
    % For low h, can be increased to 80/100
    ff = 40;
%--------------------------------------------------------------------------

%% C-Grid data are given as INPUT to the function
    % Default values for a baseline smooth grid (coarse, 100'000 elements approx) are the following
    % h      = 0.002;          % Dimension at airfoil
    % R      = 10;             % C-grid farfield dimension
    if II == 1
    H = R./15;             % Dimension at farfield for domain ind.
    elseif II == 2
    H = 400.*h;            % Dimension at farfield for grid ind.
    end
    Href   = 13.*h;           % Dimension at refinement box boundary
    Rref   = 0.6;            % C-grid refinement box dimension
%--------------------------------------------------------------------------

%% Airfoil data import
data_airfoil = airfoilCoordinatesCFD(x, h);
%--------------------------------------------------------------------------

%% Airfoil points
n = length(data_airfoil.x);
A = zeros(n, 5);
if hh == 1
    for i=1:n
       A(i,1)=i; 
       A(i,2)=data_airfoil.x(i);   
       A(i,3)=data_airfoil.y(i);         
       A(i,4)=0;        % z=0 (2D mesh)
       A(i,5)=h;
    end
elseif hh == 2
    for i=1:n
       A(i,1)=i; 
       A(i,2)=data_airfoil.x(i);   
       A(i,3)=data_airfoil.y(i);         
       A(i,4)=0;        % z=0 (2D mesh)
       A(i,5)=data_airfoil.h_vect(i);
    end
end
%--------------------------------------------------------------------------

%% C-Grid points
A(802,:) = [802, 2*R, -R, 0, H/2.2];    % basso dx
A(803,:) = [803, 2*R, R, 0, H/2.2];     % alto dx
A(804,:) = [804, 0.25, R, 0, H];        % alto sx
A(805,:) = [805, 0.25, 0, 0, H];        % centro cerchio
A(806,:) = [806, 0.25, -R, 0, H];       % basso dx
%--------------------------------------------------------------------------

%% Refinement C-Grid points
A(807,:) = [807, 1.7*R, -2*Rref, 0, 3.5*Href];    % basso dx
A(808,:) = [808, 1.7*R, 2*Rref, 0, 3.5*Href];     % alto dx
A(809,:) = [809, 0.25, Rref, 0, Href];            % alto sx
A(810,:) = [810, 0.25, 0, 0, Href];               % centro cerchio
A(811,:) = [811, 0.25, -Rref, 0, Href];           % basso dx


%% Printing
% GMSH geometry file is stored as .geo file
fileID = fopen('meshG7.geo','w');

% Scrittura di tutti i punti airfoil + C-grid
for i=1:size(A,1)
fprintf(fileID,'Point(%d)={%d,%d,%d,%d};\n',A(i,:));
end

% Scrittura delle spline che definiscono l'airfoil
fprintf(fileID,'Spline(1)={1:201};\n');
fprintf(fileID,'Spline(2)={201:401};\n');
fprintf(fileID,'Spline(3)={401:601};\n');
fprintf(fileID,'Spline(4)={601:800,1};\n');

% Scrittura delle linee e del semicerchio della C-Grid di farfield
fprintf(fileID,'Line(5)={802,803};\n');
fprintf(fileID,'Line(6)={803,804};\n');
fprintf(fileID,'Circle(7)={804,805,806};\n');
fprintf(fileID,'Line(8)={806,802};\n');

% Scrittura delle linee e del semicerchio della C-Grid a ventaglio (Ref. Box)
fprintf(fileID,'Line(15)={807,808};\n');
fprintf(fileID,'Line(16)={808,809};\n');
fprintf(fileID,'Circle(17)={809,810,811};\n');
fprintf(fileID,'Line(18)={811,807};\n');

% Scrittura dei loop
% Interno (Airfoil)
fprintf(fileID,'Line Loop(1)={1,2,3,4};\n');
% Ref. Box. (C-grid a ventaglio)
fprintf(fileID,'Line Loop(2)={15,16,17,18};\n');
% Farfield (C-grid)
fprintf(fileID,'Line Loop(3)={5,6,7,8};\n');

if BL == 1
fprintf(fileID,'Field[1]=BoundaryLayer;\n');
fprintf(fileID,'Field[1].CurvesList={1,2,3,4};\n');
fprintf(fileID,'Field[1].Quads=1;\n');
fprintf(fileID,'Field[1].Ratio=1.11;\n');
fprintf(fileID,'Field[1].Size=%d;\n',ss);
fprintf(fileID,'Field[1].Thickness=0.009;\n');
fprintf(fileID,'Field[1].FanPointsList={1};\n');
fprintf(fileID,'Field[1].FanPointsSizesList={%d};\n',ff);
fprintf(fileID,'BoundaryLayer Field = 1;\n');
end

% Scrittura della superficie da meshare
fprintf(fileID,'Plane Surface(1) = {1,2};\n');
fprintf(fileID,'Plane Surface(2) = {2,3};\n');
fprintf(fileID,'Physical Surface(1) = {1};\n');
fprintf(fileID,'Physical Surface(2) = {2};\n');

% Scrittura delle linee di inlet, outlet e airfoil
fprintf(fileID,'Physical Line("AIRFOIL") = {1,2,3,4};\n');
fprintf(fileID,'Physical Line("FARFIELD") = {5,6,7,8};\n');

% Scrittura dell'algoritmo di meshing
fprintf(fileID,'Mesh.Algorithm = 5;\n');

fclose(fileID);