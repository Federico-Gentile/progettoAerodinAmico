function out = runXFOIL(sett)
% RUNXFOIL generates the input file for Xfoil and runs Xfoil on user
% defined grid (machVechRoot, sett.XFOIL.alphaRoot) and environment and rotor data
% (data).

% Input extraction
rho = sett.ambData.rho;
chord = sett.rotData.c;
soundSpeed = sett.ambData.c;
mu = sett.ambData.mu;
gamma = sett.ambData.gamma;
N = sett.XFOIL.Ncrit;

% Generating XFOIL input file
fid = fopen('temporaryFiles\xfoil_input.txt','w');
fprintf(fid, 'load temporaryFiles/rootAirfoil.txt\n');
fprintf(fid, 'pane\n');
fprintf(fid, 'ppar\n');
fprintf(fid, "N " + num2str(sett.XFOIL.Npane, '%i') + "\n\n\n");
if sett.XFOIL.tgapFlag
    fprintf(fid, 'gdes\n');
    fprintf(fid, 'tgap\n');
    fprintf(fid, '0.01\n');
    fprintf(fid, '0.3\n\n');
    fprintf(fid, 'pane\n');
    fprintf(fid, 'ppar\n');
    fprintf(fid, "N " + num2str(sett.XFOIL.Npane+10, '%i') + "\n\n\n");    
end
fprintf(fid, 'oper\n');
fprintf(fid, 'visc on\n');
fprintf(fid, '6e6\n');
fprintf(fid,'iter 200\n');
fprintf(fid, 'vpar\n');
fprintf(fid, "N " + num2str(N) + "\n\n");

nConv  = zeros(length(sett.XFOIL.machRoot), 1);   % Keep track of polar correction for each Mach number
[MACH_GRID, ALPHA_GRID] = meshgrid(sett.XFOIL.machRoot, sett.XFOIL.alphaRoot);
Y = [];
X = [];
V_cl = [];
V_cd = [];
V_cm = [];
V_cpmin = [];

for ii = 1:length(sett.XFOIL.machRoot)
    Re = rho * chord * sett.XFOIL.machRoot(ii) * soundSpeed / mu;
    if ii == 1
        fprintf(fid, "re " + num2str(Re) + "\n");
        fprintf(fid, "mach " + num2str(sett.XFOIL.machRoot(ii)) + "\n");
        fprintf(fid, 'a 0\n');
        fprintf(fid, 'pacc\n');
        fprintf(fid, 'polar.txt\n\n');
        fprintf(fid, 'cinc\n');
        fprintf(fid, "aseq " + num2str(sett.XFOIL.alphaRoot(1)) + " " + num2str(sett.XFOIL.alphaRoot(end)) + " " + num2str(sett.XFOIL.alphaRoot(2)-sett.XFOIL.alphaRoot(1)) + "\n");
        s_xfoil  = readlines('xfoil_input.txt');
        ind_re   = find(strncmp(s_xfoil, 're', 2));
        ind_mach = find(strncmp(s_xfoil, 'mach', 4));           
    else
        s_xfoil{ind_re} = ['re ' num2str(Re)];
        s_xfoil{ind_mach} = ['mach ' num2str(sett.XFOIL.machRoot(ii))];
        writelines(s_xfoil, "temporaryFiles\xfoil_input.txt")
    end   
   
    xfoilIsRunning = 1;
    system('start /B .\XFOIL\xfoil.exe < temporaryFiles\xfoil_input.txt > temporaryFiles\xfoilLog.log');
    while xfoilIsRunning == 1
        delete temporaryFiles\xfoilExecutionTime.log
        system('powershell New-TimeSpan -Start (Get-Process xfoil).StartTime > temporaryFiles\xfoilExecutionTime.log');
        lines = readlines('temporaryFiles\xfoilExecutionTime.log');
        if size(lines,1)==1
            % XFOIL process is finished
            xfoilIsRunning = 0;
        else
            xfoilRunTime = char(lines(6));
            xfoilRunTime = str2double(xfoilRunTime(21:end));
            if xfoilRunTime > sett.XFOIL.killTime
                out.criticalMat = zeros(size(MACH_GRID));
                out.failXFOIL = 4;
                out.nConv = nConv;
                system('Taskkill /F /IM xfoil.exe');
                delete polar.txt
                return
            end
        end
    end

    % Extract data from polar.txt
    polar = readmatrix('polar.txt');

    % Checking if there is any NaN in polar before doing anything else
    if anynan(polar(:,:))
        % Excluding solutions with:
        % NaN
        out.criticalMat = zeros(size(MACH_GRID));
        out.nConv = nConv;
        out.failXFOIL = 5;
        delete polar.txt
        return
    end
    
    nConv(ii) = length(polar(:, 1));
    Y = [Y; polar(:, 1)]; %#ok<AGROW> 
    X = [X; sett.XFOIL.machRoot(ii)*ones(nConv(ii), 1)]; %#ok<AGROW> 
    V_cl = [V_cl; polar(:, 2)]; %#ok<AGROW> 
    V_cd = [V_cd; polar(:, 3)]; %#ok<AGROW> 
    V_cm = [V_cm; polar(:, 5)]; %#ok<AGROW> 
    V_cpmin = [V_cpmin; polar(:, 6)]; %#ok<AGROW> 
    
    

    if size(polar,1) >= 2 && ii == 1
        P = polyfit(polar(:,1)*pi/180, polar(:,2), 1);      
        slope = P(1);
        if slope < sett.XFOIL.thresholdClSlope
            % Excluding airfoils with shitty polar slope
            out.criticalMat = zeros(size(MACH_GRID));
            out.nConv = nConv;
            out.failXFOIL = 1;
            delete polar.txt
            return
        end
    end

    % Checking cl behavior
    if max(V_cl(polar(:, 1)>0)<0) == 1
        % Excluding solutions with:
        % - negative cl at positive alpha
        out.criticalMat = zeros(size(MACH_GRID));
        out.nConv = nConv;
        out.failXFOIL = 2;
        delete polar.txt
        return
    end
    % Checking cl behavior
    if max(polar(2:end, 2)<polar(1:end-1, 2)) == 1 
        % Excluding solutions with:
        % - non monotonic cl behavior wrt to aoa (either non converged
        % solution or early stall airfoil)
        out.criticalMat = zeros(size(MACH_GRID));
        out.nConv = nConv;
        out.failXFOIL = 3;
        delete polar.txt
        return
    end

    % Delete current polar.txt
    delete polar.txt    
end

F_cl = scatteredInterpolant(X, Y, V_cl, 'natural');
%     Cl_root = F_cl(MACH_GRID, ALPHA_GRID);
F_cd = scatteredInterpolant(X, Y, V_cd, 'natural');
%     Cd_root = F_cd(MACH_GRID, ALPHA_GRID);
F_cm = scatteredInterpolant(X, Y, V_cm, 'natural');
%     Cm_root = F_cm(MACH_GRID, ALPHA_GRID);
F_cpmin = scatteredInterpolant(X, Y, V_cpmin, 'natural');
Cpmin_root = F_cpmin(MACH_GRID, ALPHA_GRID);
Cpsonic = @(Ma) 2 * ( ( 2/(gamma+1))^(gamma/(gamma-1) ) * (1 + (gamma-1)/2*Ma.^2).^(gamma/(gamma-1)) - 1 )./ (gamma*Ma.^2);
criticalMat = Cpmin_root < Cpsonic(MACH_GRID);

% if data.plotCritMat
%     figure
%     surf(MACH_GRID,ALPHA_GRID,double(criticalMat))
% end

out.Cl = F_cl;
out.Cd = F_cd;
out.Cm = F_cm;
out.V_cl = V_cl;
out.V_cd = V_cd;
out.V_cm = V_cm;
out.alpha = Y;
out.mach = X;
out.nConv = nConv;
out.criticalMat = criticalMat;
out.failXFOIL = 0;

end