clc
clear
close all


x = 2;


% Run a series of WSL commands from MATLAB

% Specify the WSL commands you want to execute
wslCommands = ["wsl cd JST2/config",
  "wsl mpirun -n 8 SU2_CFD naca0012_JST.cfg &"];


% % Convert the commands to a single string separated by semicolons
wslCommand = strjoin(wslCommands, '; ');

% Launch WSL and execute the commands
[status, result] = system('wsl mpirun -n 4 SU2_CFD naca0012_JST.cfg; exit ' + "&");

% Check the status and display the result
if status == 0
    disp('WSL commands executed successfully.');
    disp('Output:');
    disp(result);
else
    disp('Failed to execute WSL commands.');
    disp('Error message:');
    disp(result);
end



% Command to be executed in the background
command = "nohup wsl <your command>";

% Execute the command in the background
system(command + " >/dev/null 2>&1 &");