function out = runXFOIL(machVecRoot, alphaVecRoot, data)
% RUNXFOIL generates the input file for Xfoil and runs Xfoil on user
% defined grid (machVechRoot, alphaVecRoot) and environment and rotor data
% (data).
    
    rho = data.rho;
    chord = data.chord;
    soundSpeed = data.soundSpeed;
    mu = data.mu;
    gamma = data.gamma;
    N = data.N;
    transition = data.transition;
    
    fid = fopen('xfoil_input.txt','w');
    fprintf(fid, 'load rootAirfoil.txt\n');
    fprintf(fid, 'pane\n');
    fprintf(fid, 'ppar\n');
    fprintf(fid, 'N 200\n\n\n');
    if data.tgapFlag
        fprintf(fid, 'gdes\n');
        fprintf(fid, 'tgap\n');
        fprintf(fid, '0.01\n');
        fprintf(fid, '0.3\n\n');
        fprintf(fid, 'pane\n');
        fprintf(fid, 'ppar\n');
        fprintf(fid, 'N 210\n\n\n');    
    end
    fprintf(fid, 'oper\n');
    fprintf(fid, 'visc on\n');
    fprintf(fid, '6e6\n');
    fprintf(fid,'iter 200\n');
    fprintf(fid, 'vpar\n');
    if transition == 0
        fprintf(fid, 'xtr\n');
        fprintf(fid, '0.05\n');
        fprintf(fid, '0.05\n\n');
    elseif transition == 1
        fprintf(fid, "N " + num2str(N) + "\n\n");
    end
    
    nConv  = zeros(length(machVecRoot), 1);   % Keep track of polar correction for each Mach number
    [MACH_GRID, ALPHA_GRID] = meshgrid(machVecRoot, alphaVecRoot);
    Y = [];
    X = [];
    V_cl = [];
    V_cd = [];
    V_cm = [];
    V_cpmin = [];
    
    for ii = 1:length(machVecRoot)
        Re = rho * chord * machVecRoot(ii) * soundSpeed / mu;
        if ii == 1
            fprintf(fid, "re " + num2str(Re) + "\n");
            fprintf(fid, "mach " + num2str(machVecRoot(ii)) + "\n");
            fprintf(fid, 'a 0\n');
            fprintf(fid, 'pacc\n');
            fprintf(fid, 'polar.txt\n\n');
            fprintf(fid, 'cinc\n');
            fprintf(fid, "aseq " + num2str(alphaVecRoot(1)) + " " + num2str(alphaVecRoot(end)) + " " + num2str(alphaVecRoot(2)-alphaVecRoot(1)) + "\n");
            s_xfoil  = readlines('xfoil_input.txt');
            ind_re   = find(strncmp(s_xfoil, 're', 2));
            ind_mach = find(strncmp(s_xfoil, 'mach', 4));           
        else
            s_xfoil{ind_re} = ['re ' num2str(Re)];
            s_xfoil{ind_mach} = ['mach ' num2str(machVecRoot(ii))];
            writelines(s_xfoil, "xfoil_input.txt")
        end    
        system('.\XFOIL\xfoil.exe < xfoil_input.txt; exit')

        % Extract data from polar.txt
        polar = readmatrix('polar.txt');
        nConv(ii) = length(polar(:, 1));
        Y = [Y; polar(:, 1)]; %#ok<AGROW> 
        X = [X; machVecRoot(ii)*ones(nConv(ii), 1)]; %#ok<AGROW> 
        V_cl = [V_cl; polar(:, 2)]; %#ok<AGROW> 
        V_cd = [V_cd; polar(:, 3)]; %#ok<AGROW> 
        V_cm = [V_cm; polar(:, 5)]; %#ok<AGROW> 
        V_cpmin = [V_cpmin; polar(:, 6)]; %#ok<AGROW> 

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

    if data.plotCritMat
        figure
        surf(MACH_GRID,ALPHA_GRID,double(criticalMat))
    end
    
    out.Cl = F_cl;
    out.Cd = F_cd;
    out.Cm = F_cm;
    out.nConv = nConv;
    out.criticalMat = criticalMat;
end