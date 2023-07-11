%%%%% Set environment variables to MATLAB shell path %%%%%
% This step is necessary to run any wsl program from MATLAB scripts.
% This script must be run whenever a new MATLAB session is started

% SU2_RUNS add

% setenv('PATH', [getenv('PATH') ';\\wsl.localhost\Ubuntu\home\fede\Codes\SU2_bin\bin'])
setenv('PATH', [getenv('PATH') ';\\wsl.localhost\Ubuntu\home\matteo\codes\su2\SU2_bin\bin'])

% gmsh add
% setenv('PATH', [getenv('PATH') ';\\wsl.localhost\Ubuntu\home\fede\Codes\gmsh-4.10.5-Linux64\bin'])
setenv('PATH', [getenv('PATH') ';\\wsl.localhost\Ubuntu\home\matteodallo\cfd\gmsh-4.10.5-Linux64\bin'])

% check path
!wsl env