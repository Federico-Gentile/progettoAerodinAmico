% Template description
template.description = "Test template from CFD Project\n" + ...
                       "NACA0012 at C1\n";

% QOIs names
template.QOIsNames = ["Cl", "Cd", "Cm"];

% inputMatrix contains columns of QOIs.
% example: along each row, Cl, Cd and Cm of each mesh
template.inputMatrix = [ 1.127937985	0.086933934	-0.036218773
                        1.135497648	    0.086467958	-0.035689694
                        1.127443343	    0.085065238	-0.038460054
                        1.119859926    	0.083915793	-0.040471061
                        1.121918982 	0.084009071	-0.039853792
                        1.119970181	    0.083694527	-0.040294867
                                                                ];

% meshH contains one column: h, the average element size of each mesh
template.meshH = [ 1.104050875
                   0.790679036
                   0.614476565
                   0.50955662
                   0.424503172
                   0.35384107  ];

% Richardson safety factor for GCI estimation
template.SF = 1.25;