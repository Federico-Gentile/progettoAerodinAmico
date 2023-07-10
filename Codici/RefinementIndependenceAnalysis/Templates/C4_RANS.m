% Template description
template.description = "Test template from Progetto Aerodinamico Project\n" + ...
                       "NACA0012 in C1\n";

% QOIs names
template.QOIsNames = ["Cl", "Cd", "Cm"];

% inputMatrix contains columns of QOIs.
% example: along each row, Cl, Cd and Cm of each mesh
template.inputMatrix = [   0.873252205	0.01768959	-0.020296739
                            0.864268232	0.016471013	-0.022369431
                            0.858158239	0.015910739	-0.023779739
                            0.855773601	0.015632533	-0.024269803
                            0.855640552	0.015489742	-0.024273199
                            0.856812305	0.01545388	-0.024136186 ];

% meshH contains one column: h, the average element size of each mesh
template.meshH = [ 0.864617131
                   0.635672433
                   0.459165664
                   0.32671019
                   0.229748944
                   0.181691797 ];

% Richardson safety factor for GCI estimation
template.SF = 1.25;