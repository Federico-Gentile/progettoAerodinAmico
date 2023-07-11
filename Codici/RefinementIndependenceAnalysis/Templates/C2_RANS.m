% Template description
template.description = "Test template from Progetto Aerodinamico Project\n" + ...
                       "NACA0012 in C2\n";

% QOIs names
template.QOIsNames = ["Cl", "Cd", "Cm"];

% inputMatrix contains columns of QOIs.
% example: along each row, Cl, Cd and Cm of each mesh
template.inputMatrix = [   1.103944184	0.017333881	-0.009356337
                            1.097086934	0.016077175	-0.011155834
                            1.089556725	0.015562261	-0.012696652
                            1.085437662	0.015278546	-0.013566706
                            1.084428306	0.015134508	-0.013675405
                            1.084716515	0.015055688	-0.013651618 ];

% meshH contains one column: h, the average element size of each mesh
template.meshH = [ 0.864617131
                   0.635672433
                   0.459165664
                   0.32671019
                   0.229748944
                   0.181691797 ];

% Richardson safety factor for GCI estimation
template.SF = 1.25;