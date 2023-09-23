clear; close all; clc;

x =    [10
        15
        20
        25
        30
        35
        40
        45
        50
        60
        70
        80
        100
        120
        140];

y =   [0.017748504
0.01689014
0.016470113
0.016224325
0.016067597
0.01592513
0.015853965
0.015781955
0.015739109
0.015676866
0.015596204
0.015543781
0.015476923
0.015438202
0.015434113
]; %rans cd c4

% y = [0.838981733
% 0.844944499
% 0.848774947
% 0.850460534
% 0.85200517
% 0.853073288
% 0.853868552
% 0.854378518
% 0.854879027
% 0.855792431
% 0.856159685
% 0.856343562
% 0.85698771
% 0.857240577
% 0.857657251]; %rans cl C4

y = [0.944163728
0.945004276
0.949619852
0.952645726
0.956301604
0.955382342
0.956252148
0.961277905
0.961892264
0.963061661
0.961291358
0.961573006
0.962300527
0.96159203
0.961918302]; %euler cl c4

% y = [0.011026298
% 0.009873306
% 0.009450073
% 0.009176496
% 0.00909211
% 0.008876732
% 0.008792952
% 0.008871755
% 0.0088272
% 0.008760788
% 0.008612156
% 0.008553608
% 0.008481473
% 0.008402503
% 0.008397934]; %euler cd c4

markerSize = 6;
lineSize = 1.2;
axisFontSize = 14;
legendFontSize = 10;
labelsFontSize = 22;
colorr = [0 0.4470 0.7410];
colore = [249,101,21]/255;

fig = figure; hold on;
fig.Position = [300, 300, 700, 500];
fig.Units = 'centimeters';
plot(x, y, 's', 'LineStyle', '-- ', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colore, 'MarkerEdgeColor', colore, 'MarkerFaceColor', colore);
yline(y(end)*(1+0.0015), 'LineStyle', '--', 'Color', [0.3 0.3 0.3], 'LineWidth', lineSize-0.3, 'Label', '+0.15%', 'LabelVerticalAlignment','top','LabelHorizontalAlignment','right');
yline(y(end)*(1-0.0015), 'LineStyle', '--', 'Color', [0.3 0.3 0.3], 'LineWidth', lineSize-0.3, 'Label', '-0.15%', 'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right');
set(gca, 'FontSize', axisFontSize);
xlabel('$\frac{R}{c}$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
ylabel('$C_l$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
grid minor;

exportgraphics(fig,'farfieldClEu.png','Resolution',300)



