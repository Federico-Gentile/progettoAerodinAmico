clear; close all; clc;

x =    [1.300865487
        0.887996175
        0.596127935
        0.39821364
        0.265880414];

y =    [0.873264304
        0.864266806
        0.858156123
        0.855780326
        0.855643828];

%% Processing

% Template description
template.description = "";

% QOIs names
template.QOIsNames = "Cl";

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
colorr = [0 0.4470 0.7410];

fig = figure; hold on;
fig.Position = [300, 300, 700, 500];
fig.Units = 'centimeters';
plot(x, y, 's', 'LineStyle', '-', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'MarkerFaceColor', colorr, 'DisplayName', 'Simulations');
plot([x(end); 0], [y(end); results.Cl{end,'Richardson Extrapolation'}], 's', 'LineStyle', '-- ', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'DisplayName', 'Richardson Extrapolation');
yline(y(end)*(1+0.005), 'LineStyle', '--', 'Color', [0.3 0.3 0.3], 'LineWidth', lineSize-0.3, 'Label', '+0.5%', 'LabelVerticalAlignment','top','LabelHorizontalAlignment','right', 'HandleVisibility','off');
yline(y(end)*(1-0.005), 'LineStyle', '--', 'Color', [0.3 0.3 0.3], 'LineWidth', lineSize-0.3, 'Label', '-0.5%', 'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right', 'HandleVisibility','off');
set(gca, 'FontSize', axisFontSize);
xlabel('$h$ [m]', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
ylabel('$C_l$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
grid minor;

lg = legend('Location', 'northwest');
lg.Interpreter = 'latex';
lg.FontSize = legendFontSize;


exportgraphics(fig,'refinementCl.png','Resolution',300)



