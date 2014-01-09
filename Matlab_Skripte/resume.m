fprintf('\nResuming at i=%d\n\n', i);

index = i - 1;

model = mphload(sprintf(timeStepMphPath, index));
Solver = model.sol(sprintf('sol_%d', index));

getNextSolver(0, 0, 0, index);
getNextSolverMultigrid(0, 0, 0, index);

try
    for i= index+1 : iterations   
        run('runIteration');
    end
catch msg
    tweet(['Error! Calculation canceled. '  msg.identifier]);
	rethrow (msg);
end