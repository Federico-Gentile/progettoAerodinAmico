% Template description
template.description = "Test template from CFD Project\n" + ...
                       "NACA0012 at C2\n";

% QOIs names
template.QOIsNames = ["Cl", "Cd", "Cm"];

% inputMatrix contains columns of QOIs.
% example: along each row, Cl, Cd and Cm of each mesh
template.inputMatrix = [ 1.219145995	0.003669561	0.007592085
                            1.241352265	0.002100397	0.011472161
                            1.238839989	0.001451689	0.010373862
                            1.238423263	0.001123342	0.009802975
                            1.244274581	0.001065017	0.011080084
                            1.24154138	0.000973993	0.010441135];
                                                              

% meshH contains one column: h, the average element size of each mesh
template.meshH = [ 1.104050875
                   0.790679036
                   0.614476565
                   0.50955662
                   0.424503172
                   0.35384107  ];

% Richardson safety factor for GCI estimation
template.SF = 1.25;