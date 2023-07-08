clc
clear
close all

times_h002 = [141 74 53 43 38.5];
times_h004 = [34 21 13 11.29 9.86];
cores = [1 2:2:8];

normalized_times_h002 = times_h002/141;
normalized_times_h004 = times_h004/34;

figure
plot(cores, times_h002,'LineWidth',1.2,'DisplayName','400k')
grid on
grid minor
xlabel('Cores [-]')
ylabel('t [s]')
hold on
plot(cores, times_h004,'LineWidth',1.2,'DisplayName','100k')
legend show

figure
plot(cores, normalized_times_h002,'LineWidth',1.2,'DisplayName','400k')
grid on
grid minor
xlabel('Cores [-]')
ylabel('t/t0 [-]')
hold on
plot(cores, normalized_times_h004,'LineWidth',1.2,'DisplayName','100k')
legend show