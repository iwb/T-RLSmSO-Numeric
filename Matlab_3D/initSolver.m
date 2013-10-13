function solver = initSolver( model )
	
	solver = model.sol.create('sol_1');
	solver.study('std1');
	solver.feature.create('st1', 'StudyStep');
	solver.feature('st1').set('study', 'std1');
	solver.feature('st1').set('studystep', 'time');
	solver.feature.create('v1', 'Variables');
	solver.feature('v1').set('control', 'time');
	solver.feature.create('t1', 'Time');
	solver.feature('t1').set('tlist', '0.1');
	solver.feature('t1').set('plot', 'off');
	solver.feature('t1').set('plotfreq', 'tout');
	solver.feature('t1').set('probesel', 'all');
	solver.feature('t1').set('probes', {});
	solver.feature('t1').set('probefreq', 'tsteps');
	solver.feature('t1').set('atolglobalmethod', 'scaled');
	solver.feature('t1').set('atolglobal', 0.0010);
	solver.feature('t1').set('maxorder', 2);
	solver.feature('t1').set('control', 'time');
	solver.feature('t1').feature.create('fc1', 'FullyCoupled');
	solver.feature('t1').feature('fc1').set('jtech', 'once');
	solver.feature('t1').feature('fc1').set('maxiter', 5);
	solver.feature('t1').feature.create('d1', 'Direct');
	solver.feature('t1').feature('d1').set('linsolver', 'pardiso');
	solver.feature('t1').feature('fc1').set('linsolver', 'd1');
	solver.feature('t1').feature('fc1').set('jtech', 'once');
	solver.feature('t1').feature('fc1').set('maxiter', 5);
	solver.feature('t1').feature.remove('fcDef');
	solver.attach('std1');
end