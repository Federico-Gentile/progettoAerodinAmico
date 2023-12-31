clc
clear
% close all

%% Reinitializing text files
delete optimization_diary.txt

%% Run setting
optimizationSettings;
optimizerSettings;

sett.opt.historyFilename = sett.opt.historyFilename + "_" + strrep(strrep(strrep(string(datetime('now')),':','_'),' ','_'),'-','_');
diary("histories\"+sett.opt.historyFilename+".txt");
fprintf('x1\tx2\tx3\tx4\tx5\tx6\tx7\tx8\tnconv\tP\tcoll\tT\tminAoA\tmaxAoA\tfailXFOIL\ttrimExitFlag\tsonic\textrapFlagXFOIL\textrapFlagRANS\tClAtMidSpan\tCdAtMidSpan\tClAtAlphaMax\tCdAtAlphaMax\n');
diary off

%% Computing transition indexes
[~,sett.rotSol.ind1] = min(abs(sett.rotSol.x-(sett.rotSol.tr-sett.blending.A*sett.rotData.R)));
[~,sett.rotSol.ind2] = min(abs(sett.rotSol.x-(sett.rotSol.tr+sett.blending.A*sett.rotData.R)));

% Cropping nodes
sett.rotSol.x = sett.rotSol.x([1:sett.rotSol.ind1,sett.rotSol.ind2:end]);
sett.rotSol.vi = interp1(sett.inflow.bladeStations, sett.inflow.Finfl(sett.inflow.bladeStations',sett.rotData.ACw*ones(1,length(sett.inflow.bladeStations))'), sett.rotSol.x, 'spline', 'extrap');

%% Tentative rotor solution for CFD guess
[out] = rotorSolution(sett, sett.aeroData);
x = sett.rotSol.x;
[~, ind] = min(abs(x - (sett.desVar.switchPoint + sett.blending.A)*sett.rotData.R));
indexMachCFD = ceil(linspace(ind, length(x), sett.stencil.nMachCFD));
machGridCFD = repmat(out.mach(indexMachCFD)', sett.stencil.nAlphaCFD, 1);
alphaGridCFD = repmat(linspace(min(out.alpha)-0.8, max(out.alpha)+1.1, sett.stencil.nAlphaCFD),sett.stencil.nMachCFD,1)';
machVec = reshape(machGridCFD, [], 1);
alphaVec = reshape(alphaGridCFD, [], 1);

% Searching the correction point position
[~, indAlpha] = min(abs(max(out.alpha) - alphaGridCFD));
[~, indMach] = min(abs(out.mach(out.alpha==max(out.alpha)) - machGridCFD'));

indAlpha = indAlpha(1);
indMach  = indMach(1);
indCorrectionPoint = (indMach-1)*sett.stencil.nAlphaCFD + indAlpha;
alphaCorrectionPoint = alphaVec(indCorrectionPoint);
machCorrectionPoint  = machVec(indCorrectionPoint);
if indCorrectionPoint == 1
    alphaVec = alphaVec(2:end);
    machVec  = machVec(2:end);
elseif indCorrectionPoint == length(alphaVec)
    alphaVec = alphaVec(1:end-1);
    machVec  = machVec(1:end-1);
else
    alphaVec = alphaVec([1:(indCorrectionPoint-1), (indCorrectionPoint+1):end]);
    machVec  = machVec([1:(indCorrectionPoint-1), (indCorrectionPoint+1):end]);
end
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultAxesFontSize', 16)
alphaVec = reshape(alphaGridCFD,[],1);
machVec  = reshape(machGridCFD,[],1);
figure
plot(alphaVec, machVec, 'bd', 'DisplayName','CFD Stencil','MarkerFaceColor','b','MarkerSize',6)
hold on;
plot(out.alpha, out.mach,'r', 'DisplayName','NACA 0012 Trim','LineWidth',1.2)
plot(alphaVec(11),machVec(11),'d','Color', [0.9290 0.6940 0.1250],'DisplayName','Correction Point','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerSize',10)
grid on
grid minor
xlabel('$\alpha$ [$^\circ$]', 'Interpreter','latex','FontSize',16)
ylabel('$\mathrm{Ma}$ [-]', 'Interpreter','latex','FontSize',16)
legend show
legend('Interpreter','latex','FontSize',16)
xlim([-0.3 8])
set(gca,'XTick',[0 1 2 3 4 5 6 7 8])
%% main.sh configuration
reVec = sett.ambData.rho * sett.rotData.c * machVec * sett.ambData.c/ sett.ambData.mu;
reCorrectionPoint = sett.ambData.rho * sett.rotData.c * machCorrectionPoint * sett.ambData.c/ sett.ambData.mu;
tempStringAlpha = "";
tempStringMach  = "";
tempStringRe    = "";
for ii = 1:length(alphaVec)
    tempStringAlpha = tempStringAlpha + """" + num2str(alphaVec(ii)) + """ " ;
    tempStringMach  = tempStringMach + """" + num2str(machVec(ii)) + """ " ;
    tempStringRe    = tempStringRe + """" + num2str(reVec(ii)) + """ " ;
end

text = readlines('shellScripts\main3.sh');
text(3) = "alphaGlobalVec=("+ tempStringAlpha + ")";
text(4) = "machGlobalVec=("+ tempStringMach + ")";
text(5) = "reGlobalVec=("+ tempStringRe + ")";
text(6) = "nCoresCoarse="+ num2str(sett.shell.nCoresCoarse);
text(7) = "nCoresFine="+ num2str(sett.shell.nCoresFine);
text(8) = "innerFirstIter=" + num2str(sett.shell.innerFirstIter);
text(9) = "alphaFine="""+ num2str(alphaCorrectionPoint)+ """";
text(10) = "machFine="""+ num2str(machCorrectionPoint)+ """";
text(11) = "reFine="""+ num2str(reCorrectionPoint)+ """";
writelines(text,'shellScripts\main3.sh','LineEnding','\n')

sett.stencil.alphaVec = alphaVec;
sett.stencil.machVec = machVec;
sett.stencil.alphaGridCFD = alphaGridCFD;
sett.stencil.machGridCFD = machGridCFD;
sett.stencil.alphaCorrectionPoint = alphaCorrectionPoint;
sett.stencil.machCorrectionPoint = machCorrectionPoint;
sett.stencil.indCorrectionPoint = indCorrectionPoint;
