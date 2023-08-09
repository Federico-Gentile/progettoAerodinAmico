%% Optimizer ID
sett.opt.ID = 'SU';

switch sett.opt.ID
    case 'PSO'
        % History filename
        sett.opt.historyFilename = 'PSO_history';

        % Initial swarn generation function
        % either 'random' or 'reinitialize'   
        % sett.opt.startingSwarm = 'random';
        
        % Swarm size
        sett.opt.swarmSize = 40;

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
        sett.opt.historyFilename = 'SU_history';
        sett.opt.checkPointFile =  'checkPointFile.mat';
        sett.opt.maxFunctionEvaluations = max(400,50*sett.desVar.nVars);
        sett.opt.maxTime = inf;
end
