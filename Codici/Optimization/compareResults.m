clc
clear
close all

%% Pre process

preProcess;

%% Load
profileName1 = 'OptimalAirfoil';
profileName2 = 'NACA64012';

legendName1 = 'Optimized Blade ';
legendName2 = 'NACA 64012 + Opt.Tip';

profile1 = load("out_"+profileName1+".mat");
profile2 = load("out_"+profileName2+".mat");
fontsize = 16;
%% Plotting
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultAxesFontSize', fontsize)
figure;
subplot(2,3,1)
plot(sett.rotSol.x, profile1.out.alpha,'LineWidth',1.5,'DisplayName',legendName1,'Color',[0.9290 0.6940 0.1250]); hold on;
plot(sett.rotSol.x, profile2.out.alpha,'LineWidth',1.5,'DisplayName',legendName2,'Color',[0 0.4470 0.7410]);
ylabel('$\alpha$ [$^\circ$]','Interpreter','latex','FontSize',fontsize)
xlabel('r [m]','Interpreter','latex','FontSize',fontsize)
legend show
legend('Interpreter','latex','FontSize',fontsize,'Location','northwest')
grid on 
grid minor
subplot(2,3,2)
plot(sett.rotSol.x, profile1.out.cl,'LineWidth',1.5,'DisplayName',legendName1,'Color',[0.9290 0.6940 0.1250]); hold on;
plot(sett.rotSol.x, profile2.out.cl,'LineWidth',1.5,'DisplayName',legendName2,'Color',[0 0.4470 0.7410])
ylabel('$C_l$ [-]','Interpreter','latex','FontSize',fontsize)
xlabel('r [m]','Interpreter','latex','FontSize',fontsize)
grid on 
grid minor
ylim([0 0.8])
legend show
legend('Interpreter','latex','FontSize',fontsize, 'Location','northwest')
subplot(2,3,3)
plot(sett.rotSol.x, profile1.out.cd,'LineWidth',1.5,'DisplayName',legendName1,'Color',[0.9290 0.6940 0.1250]); hold on;
plot(sett.rotSol.x, profile2.out.cd,'LineWidth',1.5,'DisplayName',legendName2,'Color',[0 0.4470 0.7410])
grid on 
grid minor
ylabel('$C_d$ [-]','Interpreter','latex','FontSize',fontsize)
xlabel('r [m]','Interpreter','latex','FontSize',fontsize)
ylim([0 14e-3])
legend show
legend('Interpreter','latex','FontSize',fontsize, 'Location','northwest')
subplot(2,3,4)
plot(sett.rotSol.x, profile1.out.Fz,'LineWidth',1.5,'DisplayName',legendName1,'Color',[0.9290 0.6940 0.1250]); hold on;
plot(sett.rotSol.x, profile2.out.Fz,'LineWidth',1.5,'DisplayName',legendName2,'Color',[0 0.4470 0.7410])
grid on 
grid minor
ylabel('$F_z$ [N/m]','Interpreter','latex','FontSize',fontsize)
xlabel('r [m]','Interpreter','latex','FontSize',fontsize)
legend show
legend('Interpreter','latex','FontSize',fontsize, 'Location','northwest')
subplot(2,3,5)
plot(sett.rotSol.x, profile1.out.Fx,'LineWidth',1.5,'DisplayName',legendName1,'Color',[0.9290 0.6940 0.1250]); hold on;
plot(sett.rotSol.x, profile2.out.Fx,'LineWidth',1.5,'DisplayName',legendName2,'Color',[0 0.4470 0.7410])
grid on 
grid minor
ylabel('$F_x$ [N/m]','Interpreter','latex','FontSize',fontsize)
xlabel('r [m]','Interpreter','latex','FontSize',fontsize)
legend show
legend('Interpreter','latex','FontSize',fontsize, 'Location','northwest')
subplot(2,3,6)
plot(sett.rotSol.x, profile1.out.Fx.*x,'LineWidth',1.5,'DisplayName',legendName1,'Color',[0.9290 0.6940 0.1250]); hold on;
plot(sett.rotSol.x, profile2.out.Fx.*x,'LineWidth',1.5,'DisplayName',legendName2,'Color',[0 0.4470 0.7410])
grid on 
grid minor
ylabel('$M_z$ [Nm/m]','Interpreter','latex','FontSize',fontsize)
xlabel('r [m]','Interpreter','latex','FontSize',fontsize)
legend show
legend('Interpreter','latex','FontSize',fontsize, 'Location','northwest')