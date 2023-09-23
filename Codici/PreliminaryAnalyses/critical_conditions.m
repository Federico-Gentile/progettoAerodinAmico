clear; close all; clc;

% Importing trim solution
load('85ktrim.mat');

% Importing critical matrix from XFOIL
load('naca0012_XFOIL_critmat100.mat');

%Graphic stuff
markerSize = 6;
lineSize = 1.2;
axisFontSize = 14;
legendFontSize = 13;
labelsFontSize = 18;

% Plotting
fig = figure; hold on;
surf(ANGLE_Cl', MACH_Cl', double(critMat'), 'HandleVisibility', 'off', 'FaceColor', 'interp', 'EdgeAlpha', 0);
surf([0 0.1; 0 0.1], [0.1 0.1; 0.2 0.2], [0, 0; 0, 0], 'DisplayName', '$C_p > C_{p \ sonic}$');
surf([0 0.1; 0 0.1], [0.1 0.1; 0.2 0.2], [0, 0; 0, 0], [1, 1; 1, 1], 'DisplayName', '$C_p < C_{p \ sonic}$');
plot3(results.RigidBlade.ACw_1.alpha, results.RigidBlade.ACw_1.mach, 2*ones(size(results.RigidBlade.ACw_1.mach)), 'r-', 'LineWidth', 2, 'DisplayName', 'Rigid Rotor Solution')
view(90, 90);
set(gca, 'XDir', 'reverse');
set(gca, 'FontSize', axisFontSize);
xlabel('$\alpha$ [$^\circ$]', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
ylabel('Ma', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
grid minor;
xlim([1.5, 6]);
ylim([0.1, 0.65]);
lg = legend('Location', 'best');
lg.Interpreter = 'latex';
lg.FontSize = legendFontSize;

exportgraphics(fig,'critcond.png','Resolution',300)

fig = figure; hold on;
plot(results.RigidBlade.ACw_1.mach, results.RigidBlade.ACw_1.cd, '-', 'LineWidth', 2);
set(gca, 'FontSize', axisFontSize);
xlabel('Ma', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
ylabel('$C_d$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
grid minor;

exportgraphics(fig,'dragriseCd.png','Resolution',300)

fig = figure; hold on;
plot(results.RigidBlade.ACw_1.mach, results.RigidBlade.ACw_1.cl, '-', 'LineWidth', 2);
set(gca, 'FontSize', axisFontSize);
xlabel('Ma', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
ylabel('$C_l$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
grid minor;



exportgraphics(fig,'dragriseCl.png','Resolution',300)
