function solver = initSolver(model, dt)
	
solver = model.sol.create('sol1');
solver.study('std1');
solver.attach('std1');
solver.feature.create('st1', 'StudyStep');
solver.feature.create('v1', 'Variables');
solver.feature.create('t1', 'Time');
solver.feature('t1').feature.create('fc1', 'FullyCoupled');
solver.feature('t1').feature.create('i1', 'Iterative');
solver.feature('t1').feature('i1').feature.create('mg1', 'Multigrid');
solver.feature('t1').feature('i1').feature('mg1').feature('pr').feature.create('sl1', 'SORLine');
solver.feature('t1').feature('i1').feature('mg1').feature('po').feature.create('sl1', 'SORLine');
solver.feature('t1').feature('i1').feature('mg1').feature('cs').feature.create('d1', 'Direct');
solver.feature('t1').feature.remove('fcDef');

solver.feature('st1').name('Compile Equations: Time Dependent {time}');
solver.feature('st1').set('studystep', 'time');
solver.feature('v1').set('control', 'time');
solver.feature('t1').set('control', 'time');
solver.feature('t1').set('tlist', dt);
solver.feature('t1').set('maxorder', '2');
solver.feature('t1').set('tstepsbdf', 'strict');
solver.feature('t1').set('solfile', false);
solver.feature('t1').set('rtol', '0.001');
solver.feature('t1').feature('fc1').set('jtech', 'once');
solver.feature('t1').feature('fc1').set('maxiter', '5');
solver.feature('t1').feature('i1').set('rhob', '20');
solver.feature('t1').feature('i1').feature('mg1').set('gmglevels', '3'); % Multigrid-Levels
solver.feature('t1').feature('i1').feature('mg1').set('scale', '3'); % Coarsening Factor
solver.feature('t1').feature('i1').feature('mg1').set('mkeep', 'on'); % Keep the meshes
solver.feature('t1').feature('i1').feature('mg1').set('mcasegen', 'coarseorder');
solver.feature('t1').feature('i1').feature('mg1').feature('pr').feature('sl1').set('relax', '0.3');
solver.feature('t1').feature('i1').feature('mg1').feature('pr').feature('sl1').set('linerelax', '0.4');
solver.feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('relax', '0.5');
solver.feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('linerelax', '0.4');
solver.feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('seconditer', '2');
solver.feature('t1').feature('i1').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');

solver.feature('v1').set('control', 'time');

solver.attach('std1');
end