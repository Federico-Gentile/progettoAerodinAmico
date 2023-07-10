% Template description
template.description = "Test template from CFD Project\n" + ...
                       "NACA230012 at 9deg\n";

% QOIs names
template.QOIsNames = ["Cd", "Cm", "Cl"];

% inputMatrix contains columns of QOIs.
% example: along each row, Cl, Cd and Cm of each mesh
template.inputMatrix = [ 0.0212 -0.0025 1.0303 
                         0.0196 -0.00210001 1.0377 
                         0.0186 -0.0021 1.0427 
                         0.0182 -0.0023 1.0454 
                         0.0178 -0.0025 1.0479 
                         0.0175 -0.0026 1.0499 ];

% meshH contains one column: h, the average element size of each mesh
template.meshH = [ 1.104050875
                   0.790679036
                   0.614476565
                   0.50955662
                   0.424503172
                   0.35384107  ];

% Richardson safety factor for GCI estimation
template.SF = 1.25;