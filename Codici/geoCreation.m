function [] = geoCreation(x)

% NOTE:
% iter contiene i_cycle (iterata del ciclo di ottimizzazione) e i_part (indice della particella)
% data_airfoil deve contenere 801 coordinate x,y dei punti del profilo
% Le coordinate x,y devono essere ottenute utilizzando la discretizzazione in x del NACA0012 di Caccia
% data_airfoil deve contenere 801 valori di h (dimensione mesh a ciascun punto)
% Il vettore h deve essere già nella sua forma finale, ovvero il prodotto
% fra il vettore h_size del NACA0012 di Caccia e una misura di riferimento (ad esempio 0.01 o 0.005)
%--------------------------------------------------------------------------
%% C-Grid data
h_mesh = 0.004;          % Can be tuned if necessary
H      = h_mesh*100;     
L      = 10;             % C-grid farfield dimension
%--------------------------------------------------------------------------

%% Airfoil data import
data_airfoil = airfoilCoordinates(x, h_mesh);
%--------------------------------------------------------------------------

%% Airfoil points
n = length(data_airfoil.x);
A = zeros(n, 5);
for i=1:n
   A(i,1)=i; 
   A(i,2)=data_airfoil.x(i);   
   A(i,3)=data_airfoil.y(i);         
   A(i,4)=0;        % z=0 (2D mesh)
   A(i,5)=data_airfoil.h(i);
end
%--------------------------------------------------------------------------

%% C-Grid points
A(802,:) = [802, 2*L, -L, 0, H];    % basso dx
A(803,:) = [803, 2*L, L, 0, H];     % alto dx
A(804,:) = [804, 0.25, L, 0, H];    % alto sx
A(805,:) = [805, 0.25, 0, 0, H];    % centro cerchio
A(806,:) = [806, 0.25, -L, 0, H];   % basso dx
%--------------------------------------------------------------------------

%% Printing
% GMSH geometry file is stored as .geo file
fileID = fopen('mesh.geo','w');

% Scrittura di tutti i punti airfoil + C-grid
for i=1:size(A,1)
fprintf(fileID,'Point(%d)={%d,%d,%d,%d};\n',A(i,:));
end

% Scrittura delle linee e del semicerchio della C-Grid
fprintf(fileID,'Line(1)={802,803};\n');
fprintf(fileID,'Line(2)={803,804};\n');
fprintf(fileID,'Circle(3)={804,805,806};\n');
fprintf(fileID,'Line(4)={806,802};\n');

% Scrittura delle spline che definiscono l'airfoil
fprintf(fileID,'Spline(5)={1:201};\n');
fprintf(fileID,'Spline(6)={201:401};\n');
fprintf(fileID,'Spline(7)={401:601};\n');
fprintf(fileID,'Spline(8)={601:800,1};\n');

% Scrittura dei loop
% Esterno (C-grid)
fprintf(fileID,'Line Loop(1)={1,2,3,4};\n');
% Interno (Airfoil)
fprintf(fileID,'Line Loop(2)={5,6,7,8};\n');

% Scrittura della superficie da meshare
fprintf(fileID,'Plane Surface(1) = {1,2};\n');
fprintf(fileID,'Physical Surface(1) = {1};\n');

% Scrittura delle linee di inlet, outlet e airfoil
% % % % fprintf(fileID,'Physical Line("INLET") = {2,3,4};\n');
% % % % fprintf(fileID,'Physical Line("OUTLET") = {1};\n');
fprintf(fileID,'Physical Line("FARFIELD") = {1,2,3,4};\n');
fprintf(fileID,'Physical Line("AIRFOIL") = {5,6,7,8};\n');

% Scrittura dell'algoritmo di meshing
fprintf(fileID,'Mesh.Algorithm = 5;\n');

fclose(fileID);