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

y =   [0.018644115
        0.017325956
        0.016667335
        0.016277842
        0.016009574
        0.015811545
        0.015659839
        0.015551785
        0.01547097
        0.015343061
        0.015235906
        0.015170702
        0.015051831
        0.014992423
        0.014953966];

markerSize = 6;
lineSize = 1.2;
axisFontSize = 14;
legendFontSize = 10;
labelsFontSize = 22;
colorr = [0 0.4470 0.7410];

fig = figure; hold on;
fig.Position = [300, 300, 700, 500];
fig.Units = 'centimeters';
plot(x, y, 's', 'LineStyle', '-- ', 'LineWidth', lineSize, 'MarkerSize', markerSize, 'Color', colorr, 'MarkerEdgeColor', colorr, 'MarkerFaceColor', colorr);
yline(y(end)*(1+0.03), 'LineStyle', '--', 'Color', [0.3 0.3 0.3], 'LineWidth', lineSize-0.3, 'Label', '+2.5%', 'LabelVerticalAlignment','top','LabelHorizontalAlignment','right');
yline(y(end)*(1-0.03), 'LineStyle', '--', 'Color', [0.3 0.3 0.3], 'LineWidth', lineSize-0.3, 'Label', '-2.5%', 'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right');
set(gca, 'FontSize', axisFontSize);
xlabel('$\frac{R}{c}$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
ylabel('$C_d$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
grid minor; ylim([0.0140 0.0190]);

exportgraphics(fig,'farfieldCd.png','Resolution',300)



