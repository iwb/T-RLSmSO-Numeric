fprintf('\nResuming at i=%d\n\n', i);

addpath('../Keyhole');
addpath('./debugging');
addpath('../PP_Zylinderquelle');

index = i - 1;

ModelUtil.showProgress(config.sim.showComsolProgress);

model = mphload(sprintf(timeStepMphPath, index));
Solver = model.sol(sprintf('sol_%d', index));

getNextSolver(0, 0, 0, index);
getNextSolverMultigrid(0, 0, 0, index);

conecount = model.geom('geom1').feature.size - 4;
updateKeyhole(0, 0, 0, 0, conecount);

if exist(logPath, 'file')
    diary(logPath);
end

try
    for i= index+1 : iterations   
        run('runIteration');
    end
catch msg
    tweet(['Error! Calculation canceled. '  msg.identifier]);
	rethrow (msg);
end