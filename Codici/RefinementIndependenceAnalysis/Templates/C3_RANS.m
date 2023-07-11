% Template description
template.description = "Test template from Progetto Aerodinamico Project\n" + ...
                       "NACA0012 in C3\n";

% QOIs names
template.QOIsNames = ["Cl", "Cd", "Cm"];

% inputMatrix contains columns of QOIs.
% example: along each row, Cl, Cd and Cm of each mesh
template.inputMatrix = [    0.328375063	0.011922948	-0.00149917
                            0.327649049	0.011508529	-0.001705843
                            0.324122575	0.011191095	-0.002427423
                            0.322520181	0.010960954	-0.002770217
                            0.322114417	0.010814559	-0.002850597
                            0.322624938	0.010731921	-0.002742378  ];

% meshH contains one column: h, the average element size of each mesh
template.meshH = [ 0.864617131
                   0.635672433
                   0.459165664
                   0.32671019
                   0.229748944
                   0.181691797 ];

% Richardson safety factor for GCI estimation
template.SF = 1.25;