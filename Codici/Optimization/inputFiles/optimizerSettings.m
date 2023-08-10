%% Optimizer ID
sett.opt.ID = 'PSO';

switch sett.opt.ID
    case 'PSO'
        % History filename
        sett.opt.historyFilename = 'PSO_history';

        % Initial swarn generation function
        % either 'random' or 'reinitialize'   
        sett.opt.startingSwarm = readmatrix('histories\PSO_history_10_Aug_2023_01_02_32.txt');
        sett.opt.startingSwarm = sett.opt.startingSwarm(1:60,1:8); % 60 cause it's dallo's swarm
        
        % Swarm size
        sett.opt.swarmSize = 60;

        % Exit criteria
        sett.opt.functionTolerance = 1e-6;
        sett.opt.maxStallIterations = 20;
        sett.opt.maxIterations = 200*sett.desVar.nVars;
        sett.opt.maxStallTime = Inf;
        sett.opt.maxTime = Inf;

        % Check function value
        sett.opt.funValCheck = 'on';

    case 'GA'

    case 'SU'
        sett.opt.runType = 'trials';    % Can be 'trials', 'checkPoint', 'normal'
        sett.opt.historyFilename = 'SU_history';
        sett.opt.checkPointFile =  'checkPointFile.mat';
        sett.opt.maxFunctionEvaluations = max(400,50*sett.desVar.nVars);
        sett.opt.maxTime = inf;
        sett.opt.minSurrPoints = 40;
end
