clear; close all; clc;

% Data
data = [1	1	140	1	140
        1	2	150	2	75
        1	4	160	4	40
        1	6	210	6	35
        1	8	240	8	30
        1	10	330	10	33
        1	12	380	12	31.66666667
        1	14	450	14	32.14285714
        2	1	90	2	90
        2	2	110	4	55
        2	4	165	8	41.25
        2	6	220	12	36.66666667
        2	8	290	16	36.25
        3	1	73	3	73
        3	2	100	6	50
        3	4	157	12	39.25
        3	5	205	15	41
        4	1	62	4	62
        4	2	95	8	47.5
        4	3	124	12	41.33333333
        4	4	178	16	44.5
        5	1	56	5	56
        5	2	92	10	46
        5	3	140	15	46.66666667];

markerSize = 6;
lineSize = 1.2;
axisFontSize = 14;
legendFontSize = 14;
labelsFontSize = 18;

colorss = [0 0.4470 0.7410	
            0.8500 0.3250 0.0980		
            0.9290 0.6940 0.1250	
            0.4940 0.1840 0.5560	
            0.4660 0.6740 0.1880	
            0.3010 0.7450 0.9330		
            0.6350 0.0780 0.1840];

% Plotting
fig = figure; hold on;
for nThread = 1:5
    Namee = ['$N_{threads \ per \ sim} = ', num2str(nThread), '$'];
    plot(data(data(:,1)==nThread, 2), data(data(:,1)==nThread, 5), 's--', 'LineWidth', 1.5, 'MarkerFaceColor', colorss(nThread, :), 'Color', colorss(nThread, :), 'MarkerEdgeColor', colorss(nThread, :), 'DisplayName', Namee)
end
set(gca, 'FontSize', axisFontSize);
xlabel('$N_{parallel \ sims}$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
ylabel('Effective Time [s]', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
grid minor;
lg = legend('Location', 'northeast');
lg.Interpreter = 'latex';
lg.FontSize = legendFontSize;

exportgraphics(fig,'EffectiveTime1.png','Resolution',600)


fig = figure; hold on;
for nThread = 1:5
    Namee = ['$N_{threads \ per \ sim} = ', num2str(nThread), '$'];
    plot(data(data(:,1)==nThread, 4), data(data(:,1)==nThread, 5), 's--', 'LineWidth', 1.5, 'MarkerFaceColor', colorss(nThread, :), 'Color', colorss(nThread, :), 'MarkerEdgeColor', colorss(nThread, :), 'DisplayName', Namee)
end
set(gca, 'FontSize', axisFontSize);
xlabel('$N_{total \ threads \ employed}$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
ylabel('Effective Time [s]', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
grid minor;
lg = legend('Location', 'northeast');
lg.Interpreter = 'latex';
lg.FontSize = legendFontSize;

exportgraphics(fig,'EffectiveTime2.png','Resolution',600)

fig = figure; hold on;
x = [0 1 4 6 8];
y1 = [1 0.62 0.376 0.32 0.278];
y2 = [1 0.52 0.36 0.301 0.26];
plot(x, y1, 's--', 'LineWidth', 1.5, 'MarkerFaceColor', colorss(1, :), 'Color', colorss(1, :), 'MarkerEdgeColor', colorss(1, :), 'DisplayName', 'G24')
plot(x, y2, 's--', 'LineWidth', 1.5, 'MarkerFaceColor', colorss(2, :), 'Color', colorss(2, :), 'MarkerEdgeColor', colorss(2, :), 'DisplayName', 'G22')
xlabel('$N_{threads}$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
ylabel('$\frac{t}{t_0}$', 'FontSize', labelsFontSize, 'Interpreter', 'latex');
grid minor;
lg = legend('Location', 'northeast');
lg.Interpreter = 'latex';
lg.FontSize = legendFontSize;

exportgraphics(fig,'EffectiveTime3.png','Resolution',600)