function out = runXFOIL(machVecRoot, alphaVecRoot, data)
    
    rho = data.rho;
    chord = data.chord;
    soundSpeed = data.soundSpeed;
    mu = data.mu;
    gamma = data.gamma;
    
    fid = fopen('xfoil_input.txt','w');
    fprintf(fid, 'load rootAirfoil.txt\n');
    fprintf(fid, 'pane\n');
    fprintf(fid, 'ppar\n');
    fprintf(fid, 'N 200\n\n\n');
    fprintf(fid, 'gdes\n');
    fprintf(fid, 'tgap\n');
    fprintf(fid, '0.01\n');
    fprintf(fid, '0.3\n\n');
    fprintf(fid, 'pane\n');
    fprintf(fid, 'ppar\n');
    fprintf(fid, 'N 210\n\n\n');    
    fprintf(fid, 'oper\n');
    fprintf(fid, 'visc on\n');
    fprintf(fid, '6e6\n');
    fprintf(fid,'iter 200\n');
    fprintf(fid, 'vpar\n');
    % fprintf(fid, 'xtr\n');
    % fprintf(fid, '0.05\n');
    % fprintf(fid, '0.05\n\n');
    fprintf(fid, 'N 3\n\n');
    
    ClRoot = zeros(length(machVecRoot), length(alphaVecRoot));
    CdRoot = zeros(length(machVecRoot), length(alphaVecRoot));
    CmRoot = zeros(length(machVecRoot), length(alphaVecRoot));
    nConv  = zeros(length(machVecRoot), 1);   % Keep track of polar correction for each Mach number
    [ALPHA_GRID, MACH_GRID] = meshgrid(alphaVecRoot, machVecRoot);
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
            fprintf(fid,'pacc\n');
            fprintf(fid,'polar.txt\n\n');
            fprintf(fid,'cinc\n');
            fprintf(fid,'aseq 0 10 0.5\n');
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
        X = [X; polar(:, 1)]; 
        Y = [Y; machVecRoot(ii)*ones(nConv(ii), 1)];
        V_cl = [V_cl; polar(:, 2)];
        V_cd = [V_cd; polar(:, 3)];
        V_cm = [V_cm; polar(:, 5)];
        V_cpmin = [V_cpmin; polar(:, 6)]; 
        % Delete current polar.txt
        delete polar.txt    
    end
    F_cl = scatteredInterpolant(X, Y, V_cl, 'natural');
    Cl_root = F_cl(ALPHA_GRID, MACH_GRID);
    F_cd = scatteredInterpolant(X, Y, V_cd, 'natural');
    Cd_root = F_cd(ALPHA_GRID, MACH_GRID);
    F_cm = scatteredInterpolant(X, Y, V_cm, 'natural');
    Cm_root = F_cm(ALPHA_GRID, MACH_GRID);
    F_cpmin = scatteredInterpolant(X, Y, V_cpmin, 'natural');
    Cpmin_root = F_cpmin(ALPHA_GRID, MACH_GRID);
    Cpsonic = @(Ma) 2 * ( ( 2/(gamma+1))^(gamma/(gamma-1) ) * (1 + (gamma-1)/2*Ma.^2).^(gamma/(gamma-1)) - 1 )./ (gamma*Ma.^2);
    criticalMat = Cpmin_root < Cpsonic(MACH_GRID);
    figure
    surf(ALPHA_GRID,MACH_GRID,double(criticalMat))
    
    out.Cl = F_cl;
    out.Cd = F_cd;
    out.Cm = F_cm;
end