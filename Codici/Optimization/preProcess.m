clc
clear
close all


%% Run setting
optimizationSettings;
%% Tentative rotor solution for CFD guess
[out] = rotorSolution(sett, sett.aeroData);
x = sett.rotSol.x;
[~, ind] = min(abs(x - (sett.desVar.switchPoint + sett.blending.A)*sett.rotData.R));
indexMachCFD = ceil(linspace(ind, length(x), sett.stencil.nMachCFD));
machGridCFD = repmat(out.mach(indexMachCFD)', sett.stencil.nAlphaCFD, 1);
alphaGridCFD = repmat(linspace(min(out.alpha)-0.6, max(out.alpha)+0.6, sett.stencil.nAlphaCFD),sett.stencil.nMachCFD,1)';
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

%% Cores distribution over tasks
remainingCores  = sett.cores.nCores - sett.cores.nCoresFine;
ransCoarsePerRound = floor(remainingCores/sett.cores.nCoresCoarse);
outerCounterMax = ceil(length(alphaVec)/ransCoarsePerRound);
innerIterVec = repmat(ransCoarsePerRound, outerCounterMax - 1, 1);
innerIterVec = [innerIterVec;length(alphaVec) - sum(innerIterVec)];

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
tempStringInner    = "";
for ii = 1:length(innerIterVec)
    tempStringInner = tempStringInner + """" + num2str(innerIterVec(ii)) + """ " ;
end


text = readlines('shellScripts\main.sh');
text(1) = "alphaGlobalVec=("+ tempStringAlpha + ")";
text(2) = "machGlobalVec=("+ tempStringMach + ")";
text(3) = "reGlobalVec=("+ tempStringRe + ")";
text(4) = "nCoresCoarse="+ num2str(sett.cores.nCoresCoarse);
text(5) = "nCoresFine="+ num2str(sett.cores.nCoresFine);
text(6) = "innerIterVec=("+ tempStringInner + ")";
text(7) = "alphaFine="""+ num2str(alphaCorrectionPoint)+ """";
text(8) = "machFine="""+ num2str(machCorrectionPoint)+ """";
text(9) = "reFine="""+ num2str(reCorrectionPoint)+ """";
text(10)= "outerCounterMax=" + num2str(outerCounterMax) ;
writelines(text,'shellScripts\main.sh','LineEnding','\n')
