clear; close all; clc;
addpath('Scripts\');

% x = [0.864617131
% 0.635672433
% 0.459165664
% 0.32671019
% 0.229748944]; % rans 

x = [1.300865487
0.887996175
0.596127935
0.39821364
0.265880414]; % euler

x = x(1:end-1);

% colorr = [0 0.4470 0.7410]; % rans
colorr = [249,101,21]/255; % euler


template.QOIsNames = "Cl";
% 
% y =    [0.873264304
%         0.864266806
%         0.858156123
%         0.855780326
%         0.855643828]; % rans Cl C4

y = [0.959581377
0.966107043
0.961204254
0.958502406]; % euler Cl C4

% 
% template.QOIsNames = "Cd";
% 
% y = [0.017689845
% 0.016470976
% 0.01591069
% 0.015632304
% 0.01548964]; % rans Cd C4

y = [0.010653059
0.009510704
0.008849511
0.008540141]; % euler Cd C4





%% Processing

% Template description
template.description = "";


% inputMatrix contains columns of QOIs.
% example: along each row, Cl, Cd and Cm of each mesh
template.inputMatrix = y;

% meshH contains one column: h, the average element size of each mesh
template.meshH = x;

% Richardson safety factor for GCI estimation
template.SF = 1.25;

dataProcessing;

%% Plot

markerSize = 6;
lineSize = 1.2;
axisFontSize = 14;
legendFontSize = 20;
labelsFontSize = 22;

% Cl figure RANS
% fig = figure; hold on;
% fig.Position = [300, 300, 700, 500];
% fig.Units = 'centimeters';
% plot(x, y, 's', 'LineStyle', '-', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'MarkerFaceColor', colorr, 'DisplayName', 'Simulations');
% plot([x(end); 0], [y(end); results.(template.QOIsNames){end,'Richardson Extrapolation'}], 's', 'LineStyle', '-- ', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'DisplayName', 'Richardson Extr.');
% errorbar(x(3:end), y(3:end), y(3:end)/100.*results.(template.QOIsNames){:,'GCI fine %'}, 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'MarkerFaceColor', colorr, 'HandleVisibility', 'off')
% text(x(3)-0.04, y(3)*(1+1/100.*results.(template.QOIsNames){1,'GCI fine %'})+8.7199e-04, [num2str(results.(template.QOIsNames){1,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
% text(x(4)-0.04, y(4)*(1+1/100.*results.(template.QOIsNames){2,'GCI fine %'})+8.7199e-04, [num2str(results.(template.QOIsNames){2,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
% text(x(5)-0.04, y(5)*(1+1/100.*results.(template.QOIsNames){3,'GCI fine %'})+1.5*8.7199e-04, [num2str(results.(template.QOIsNames){3,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
% set(gca, 'FontSize', axisFontSize);
% xlabel('$h$ [m]', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
% ylabel('$C_l$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
% grid minor;
% lg = legend('Location', 'southeast');
% lg.Interpreter = 'latex';
% lg.FontSize = legendFontSize;
% exportgraphics(fig,'refClRANS.png','Resolution',300)

% Cl figure EULER
% fig = figure; hold on;
% fig.Position = [300, 300, 700, 500];
% fig.Units = 'centimeters';
% plot(x, y, 's', 'LineStyle', '-', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'MarkerFaceColor', colorr, 'DisplayName', 'Simulations');
% plot([x(end); 0], [y(end); results.(template.QOIsNames){end,'Richardson Extrapolation'}], 's', 'LineStyle', '-- ', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'DisplayName', 'Richardson Extr.');
% errorbar(x(3:end), y(3:end), y(3:end)/100.*results.(template.QOIsNames){:,'GCI fine %'}, 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'MarkerFaceColor', colorr, 'HandleVisibility', 'off')
% text(x(3)-0.0517, y(3)*(1+1/100.*results.(template.QOIsNames){1,'GCI fine %'})+8.7199e-04, [num2str(results.(template.QOIsNames){1,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
% text(x(4)-0.0517, y(4)*(1+1/100.*results.(template.QOIsNames){2,'GCI fine %'})+8.7199e-04, [num2str(results.(template.QOIsNames){2,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
% set(gca, 'FontSize', axisFontSize);
% xlabel('$h$ [m]', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
% ylabel('$C_l$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
% grid minor;
% lg = legend('Location', 'southeast');
% lg.Interpreter = 'latex';
% lg.FontSize = legendFontSize;
% exportgraphics(fig,'refClEULER.png','Resolution',300)


% Cd figure RANS
% fig = figure; hold on;
% fig.Position = [300, 300, 700, 500];
% fig.Units = 'centimeters';
% plot(x, y, 's', 'LineStyle', '-', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'MarkerFaceColor', colorr, 'DisplayName', 'Simulations');
% plot([x(end); 0], [y(end); results.(template.QOIsNames){end,'Richardson Extrapolation'}], 's', 'LineStyle', '-- ', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'DisplayName', 'Richardson Extr.');
% errorbar(x(3:end), y(3:end), y(3:end)/100.*results.(template.QOIsNames){:,'GCI fine %'}, 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'MarkerFaceColor', colorr, 'HandleVisibility', 'off')
% text(x(3)-0.04, y(3)*(1+1/100.*results.(template.QOIsNames){1,'GCI fine %'})+0.1*8.7199e-04, [num2str(results.(template.QOIsNames){1,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
% text(x(4)-0.04, y(4)*(1+1/100.*results.(template.QOIsNames){2,'GCI fine %'})+0.1*8.7199e-04, [num2str(results.(template.QOIsNames){2,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
% text(x(5)-0.04, y(5)*(1+1/100.*results.(template.QOIsNames){3,'GCI fine %'})+0.1*8.7199e-04, [num2str(results.(template.QOIsNames){3,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
% set(gca, 'FontSize', axisFontSize);
% xlabel('$h$ [m]', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
% ylabel('$C_d$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
% grid minor;
% lg = legend('Location', 'northwest');
% lg.Interpreter = 'latex';
% lg.FontSize = legendFontSize;
% exportgraphics(fig,'refCdRANS.png','Resolution',300)

% CD figure EULER
fig = figure; hold on;
fig.Position = [300, 300, 700, 500];
fig.Units = 'centimeters';
plot(x, y, 's', 'LineStyle', '-', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'MarkerFaceColor', colorr, 'DisplayName', 'Simulations');
plot([x(end); 0], [y(end); results.(template.QOIsNames){end,'Richardson Extrapolation'}], 's', 'LineStyle', '-- ', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'DisplayName', 'Richardson Extr.');
errorbar(x(3:end), y(3:end), y(3:end)/100.*results.(template.QOIsNames){:,'GCI fine %'}, 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'MarkerFaceColor', colorr, 'HandleVisibility', 'off')
text(x(3)-0.0517, y(3)*(1+1/100.*results.(template.QOIsNames){1,'GCI fine %'})+0.9199e-04, [num2str(results.(template.QOIsNames){1,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
text(x(4)-0.0517, y(4)*(1+1/100.*results.(template.QOIsNames){2,'GCI fine %'})+0.9199e-04, [num2str(results.(template.QOIsNames){2,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
% text(x(5)-0.0517, y(5)*(1+1/100.*results.(template.QOIsNames){3,'GCI fine %'})+0.9199e-04, [num2str(results.(template.QOIsNames){3,'GCI fine %'}, '%.3f'), ' %'], 'Color', colorr);
set(gca, 'FontSize', axisFontSize);
xlabel('$h$ [m]', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
ylabel('$C_d$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
grid minor;
lg = legend('Location', 'southeast');
lg.Interpreter = 'latex';
lg.FontSize = legendFontSize;
exportgraphics(fig,'refCDEULER.png','Resolution',300)



