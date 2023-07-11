% Template description
template.description = "Test template from Progetto Aerodinamico Project\n" + ...
                       "NACA0012 in C1\n";

% QOIs names
template.QOIsNames = ["Cl", "Cd", "Cm"];

% inputMatrix contains columns of QOIs.
% example: along each row, Cl, Cd and Cm of each mesh
template.inputMatrix = [   0.89135239	0.074936256	-0.047352497
0.868716438	0.073754152	-0.045911716
0.845772819	0.072879197	-0.044283271
0.826796049	0.071999386	-0.043806461
 ];

% meshH contains one column: h, the average element size of each mesh
template.meshH = [1.421363285
1.411001634
1.459971099
1.463341898
];

% Richardson safety factor for GCI estimation
template.SF = 1.25;