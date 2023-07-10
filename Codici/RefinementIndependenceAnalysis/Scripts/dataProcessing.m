% Checking proper input size
if size(template.inputMatrix,1) ~= size(template.meshH,1)
    error('Incoherent inputMatrix and meshH sizes!');
end

% Looping over triplets
nAnalyses = length(template.meshH)-2;
nQOIs = length(template.QOIsNames);

% Initializing results structure
results = struct();

for jj = 1:nQOIs

    % Initializing outputs
    results.(template.QOIsNames(jj)) = array2table(NaN(nAnalyses,7));
    results.(template.QOIsNames(jj)).Properties.VariableNames = ["p", "Richardson Extrapolation", "GCI fine", "GCI coarse", "Check", "Fsolve exitFlag", "Residual"];

    for ii = 1:nAnalyses

        % Defining inputs for Richardson analysis
        f3 = template.inputMatrix(ii,jj);
        f2 = template.inputMatrix(ii+1,jj);
        f1 = template.inputMatrix(ii+2,jj);
        r32 = template.meshH(ii)/template.meshH(ii+1);
        r21 = template.meshH(ii+1)/template.meshH(ii+2);

        % Performing Richardson analysis
        [p, ext, GCI21, GCI32, check, exitFlag, residual] = richardsonAnalysis(r21, r32, f1, f2, f3, template.SF);

        % Organizing results
        results.(template.QOIsNames(jj)){ii,1} = p;
        results.(template.QOIsNames(jj)){ii,2} = ext;
        results.(template.QOIsNames(jj)){ii,3} = GCI21;
        results.(template.QOIsNames(jj)){ii,4} = GCI32;
        results.(template.QOIsNames(jj)){ii,5} = check;
        results.(template.QOIsNames(jj)){ii,6} = exitFlag;
        results.(template.QOIsNames(jj)){ii,7} = residual;

    end
end

clearvars f1 f2 f3 r21 r32 p ext check exitFlag residual GCI21 GCI32 ii jj