% Template description
template.description = "Test template from Progetto Aerodinamico Project\n" + ...
                       "NACA0012 in C1\n";

% QOIs names
template.QOIsNames = ["Cl", "Cd", "Cm"];

% inputMatrix contains columns of QOIs.
% example: along each row, Cl, Cd and Cm of each mesh
template.inputMatrix = [    0.925794346	0.075885692	-0.05164316
                            0.888265094	0.075029824	-0.045848642
                            0.859786408	0.074035813	-0.043848094
                            0.839257048	0.073071773	-0.043184225
                            0.822193766	0.072098408	-0.042952616
                            0.811879118	0.071409287	-0.043082986 ];

% meshH contains one column: h, the average element size of each mesh
template.meshH = [ 1.300865487
                    0.887996175
                    0.596127935
                    0.39821364
                    0.265880414
                    0.205049156
                     ];

% Richardson safety factor for GCI estimation
template.SF = 1.25;