clc
clear
close all

%% Run setting
optimizationSettings;
load('naca0012_RANS.mat')
cl = griddedInterpolant(MACH_Cl', ANGLE_Cl', Cl');
cd = griddedInterpolant(MACH_Cd', ANGLE_Cd', Cd');
cm = griddedInterpolant(MACH_Cm', ANGLE_Cm', Cm');
aeroData{1}.cl = cl;
aeroData{1}.cd = cd;
aeroData{1}.cm = cm;
aeroData{2}.cl = cl;
aeroData{2}.cd = cd;
aeroData{2}.cm = cm;
%% Tentative rotor solution for CFD guess
[out] = rotorSolution(sett, aeroData);
x = sett.rotSol.x;
[~, ind] = min(abs(x - (sett.desVar.switchPoint + sett.blending.A)*sett.rotData.R));
nMachCFD =4;
indexMachCFD = ceil(linspace(ind, length(x), nMachCFD));
nAlphaCFD = 6;
machGridCFD = repmat(out.mach(indexMachCFD)', nAlphaCFD, 1);
alphaGridCFD1 = repmat(out.alpha(indexMachCFD)', nAlphaCFD, 1) + linspace(-2, 2, nAlphaCFD)';
alphaGridCFD = repmat(linspace(min(out.alpha)-2, max(out.alpha)+2, nAlphaCFD),nMachCFD,1)';
machVec = out.mach(indexMachCFD)';
alphaVec = reshape(alphaGridCFD, [], 1);
alphaVec1 = reshape(alphaGridCFD1, [], 1);

INmat = ones(nAlphaCFD, nMachCFD);
for jj = 1:nMachCFD
    for ii = 1:nAlphaCFD
        if alphaGridCFD(ii,jj) < alphaGridCFD1(1,jj) - 4*(alphaVec(2) - alphaVec(1)) || alphaGridCFD(ii,jj) > alphaGridCFD1(end,jj) + 4*(alphaVec(2) - alphaVec(1)) 
            INmat(ii,jj) = 0;
        end
    end
end


INvec = reshape(INmat, [], 1);
zscaled = INvec*10+1;                                             % May Be Necessary To Scale The Colour Vector
cn = ceil(max(zscaled));                                        % Number Of Colors (Scale AsAppropriate)
cm = colormap(jet(cn));                                         % Define Colormap

figure();
plot(alphaGridCFD, machGridCFD, 'ko', 'DisplayName','GRID')
hold on;
plot(alphaGridCFD1, machGridCFD, 'ro', 'DisplayName','GRID')
scatter3(alphaVec, reshape(machGridCFD, [], 1),INvec, [], cm(ceil(zscaled),:),  'filled')
plot(out.alpha, out.mach, 'DisplayName','RANS NACA0012')
xlabel('alpha')
ylabel('mach')
legend()

% %% Cl interpolation error
% FF =@(x, y) griddata(reshape(machGridCFD,[], 1), reshape(alphaGridCFD, [], 1),reshape(aeroData{1}.cl(machGridCFD, alphaGridCFD), [], 1), x, y, 'cubic');
% figure();
% [xx, yy] = meshgrid(linspace(out.mach(ind), out.mach(end), 100), linspace(min(out.alpha)-2, max(out.alpha)+2, 100));
% surf(xx, yy, abs(FF(xx, yy)-aeroData{1}.cl(xx, yy))./aeroData{1}.cl(xx, yy),'FaceAlpha', 0.5);
% hold on
% plot3(out.mach, out.alpha, zeros(length(out.mach),length(out.alpha)),'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4,'LineStyle','none');
% plot3(machGridCFD, alphaGridCFD, zeros(size(machGridCFD)),'ko')
% 
% figure
% surf(xx, yy, FF(xx, yy), 'FaceColor', 'r');
% hold on
% surf(xx, yy, aeroData{1}.cl(xx, yy));
% plot3(machGridCFD, alphaGridCFD,aeroData{1}.cl(machGridCFD, alphaGridCFD), 'ro')
% 
% figure
% plot3(out.mach(ind+1: end), out.alpha(ind+1: end), aeroData{1}.cl(out.mach(ind+1: end), out.alpha(ind+1:end)), 'LineWidth',3)
% view(2)
% colorbar()
% 
% %% Cl interpolation error
% FF =@(x, y) griddata(reshape(machGridCFD,[], 1), reshape(alphaGridCFD, [], 1),reshape(aeroData{1}.cd(machGridCFD, alphaGridCFD), [], 1), x, y, 'cubic');
% figure();
% [xx, yy] = meshgrid(linspace(out.mach(ind), out.mach(end), 100), linspace(min(out.alpha)-2, max(out.alpha)+2, 100));
% surf(xx, yy, abs(FF(xx, yy)-aeroData{1}.cd(xx, yy))./aeroData{1}.cd(xx, yy),'FaceAlpha', 0.5);
% hold on
% plot3(out.mach, out.alpha, zeros(length(out.mach),length(out.alpha)),'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4,'LineStyle','none');
% plot3(machGridCFD, alphaGridCFD, zeros(size(machGridCFD)),'ko')
% 
% figure
% surf(xx, yy, FF(xx, yy), 'FaceColor', 'r');
% hold on
% surf(xx, yy, aeroData{1}.cd(xx, yy));
% plot3(machGridCFD, alphaGridCFD,aeroData{1}.cd(machGridCFD, alphaGridCFD), 'ro')
% 
% figure
% plot3(out.mach(ind+1: end), out.alpha(ind+1: end), aeroData{1}.cd(out.mach(ind+1: end), out.alpha(ind+1:end)), 'LineWidth',3)
% view(2)
% colorbar()
% 
% 
%% Fitting Cl
machVec = reshape(machGridCFD,[],1);
alphaVec = reshape(alphaGridCFD,[],1);

clFit = fit([machVec alphaVec], reshape(aeroData{1}.cl(machGridCFD, alphaGridCFD), [], 1),'poly33');

figure
surf(xx, yy, abs(clFit(xx, yy)-aeroData{1}.cl(xx, yy))./aeroData{1}.cl(xx, yy),'FaceAlpha', 0.5);
hold on
plot3(out.mach, out.alpha, zeros(length(out.mach),length(out.alpha)),'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4,'LineStyle','none');
plot3(machGridCFD, alphaGridCFD, zeros(size(machGridCFD)),'ko')

figure
surf(xx, yy, clFit(xx, yy), 'FaceColor', 'r');
hold on
surf(xx, yy, aeroData{1}.cl(xx, yy));
plot3(machGridCFD, alphaGridCFD,aeroData{1}.cl(machGridCFD, alphaGridCFD), 'ro')


%% Fitting Cd
cdFit = fit([machVec alphaVec], reshape(aeroData{1}.cd(machGridCFD, alphaGridCFD), [], 1),'poly33');

figure
surf(xx, yy, abs(cdFit(xx, yy)-aeroData{1}.cd(xx, yy))./aeroData{1}.cd(xx, yy),'FaceAlpha', 0.5);
hold on
plot3(out.mach, out.alpha, zeros(length(out.mach),length(out.alpha)),'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4,'LineStyle','none');
plot3(machGridCFD, alphaGridCFD, zeros(size(machGridCFD)),'ko')
zlim([0 0.1])

figure
surf(xx, yy, cdFit(xx, yy), 'FaceColor', 'r');
hold on
surf(xx, yy, aeroData{1}.cd(xx, yy));
plot3(machGridCFD, alphaGridCFD,aeroData{1}.cd(machGridCFD, alphaGridCFD), 'ro')


%% Interp2 cl
CL = aeroData{1}.cl(machGridCFD, alphaGridCFD);
CD = aeroData{1}.cd(machGridCFD, alphaGridCFD);
CL = CL.*INmat;
CD = CD.*INmat;


for jj = 1:nMachCFD
    count = 0;
    flag = 0;
    for ii = 1:nAlphaCFD
        if INmat(ii,jj) == 0
           count = count +1;
        elseif flag == 0
            for kk = ii-count:ii
                CL(kk,jj) = CL(ii,jj);
                CD(kk,jj) = CD(ii,jj);                
            end
            flag = 1;
        end

    end
end

for jj = nMachCFD:-1:1
    count = 0;
    flag = 0;
    for ii = nAlphaCFD:-1:1
        if INmat(ii,jj) == 0
           count = count +1;
        elseif flag == 0
            for kk = ii:ii+count
                CL(kk,jj) = CL(ii,jj);
                CD(kk,jj) = CD(ii,jj);                
            end
            flag = 1;
        end

    end
end



FF = @(x, y) interp2(machGridCFD, alphaGridCFD, CL, x, y, 'spline');
figure();
[xx, yy] = meshgrid(linspace(out.mach(ind), out.mach(end), 100), linspace(min(out.alpha)-2, max(out.alpha)+2, 100));
surf(xx, yy, abs(FF(xx, yy)-aeroData{1}.cl(xx, yy))./aeroData{1}.cl(xx, yy),'FaceAlpha', 0.5);
hold on
plot3(out.mach, out.alpha, zeros(length(out.mach),length(out.alpha)),'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4,'LineStyle','none');
plot3(machGridCFD, alphaGridCFD, zeros(size(machGridCFD)),'ko')
zlim([0 0.1])
figure
surf(xx, yy, FF(xx, yy), 'FaceColor', 'r');
hold on
surf(xx, yy, aeroData{1}.cl(xx, yy));
plot3(machGridCFD, alphaGridCFD,aeroData{1}.cl(machGridCFD, alphaGridCFD), 'ro')

figure
plot3(out.mach(ind+1: end), out.alpha(ind+1: end), aeroData{1}.cl(out.mach(ind+1: end), out.alpha(ind+1:end)), 'LineWidth',3)
view(2)
colorbar()

%% Interp2 cd
FF = @(x, y) interp2(machGridCFD, alphaGridCFD, CD, x, y, 'spline');
figure();
[xx, yy] = meshgrid(linspace(out.mach(ind), out.mach(end), 100), linspace(min(out.alpha)-2, max(out.alpha)+2, 100));
surf(xx, yy,(FF(xx, yy)-aeroData{1}.cd(xx, yy))./aeroData{1}.cd(xx, yy),'FaceAlpha', 0.5);
hold on
plot3(out.mach, out.alpha, zeros(length(out.mach),length(out.alpha)),'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4,'LineStyle','none');
plot3(machGridCFD, alphaGridCFD, zeros(size(machGridCFD)),'ko')
zlim([-0.1 0.1])

figure
surf(xx, yy, FF(xx, yy), 'FaceColor', 'r');
hold on
surf(xx, yy, aeroData{1}.cd(xx, yy));
plot3(machGridCFD, alphaGridCFD,aeroData{1}.cd(machGridCFD, alphaGridCFD), 'ro')

figure
plot3(out.mach(ind+1: end), out.alpha(ind+1: end), aeroData{1}.cd(out.mach(ind+1: end), out.alpha(ind+1:end)), 'LineWidth',3)
view(2)
colorbar()