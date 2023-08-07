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
