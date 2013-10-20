function [ New_Solver ] = getNextSolver(Model, Old_Solver, dt)
%NEXT_SOLVER Summary of this function goes here
%   Detailed explanation goes here

	import com.comsol.model.*
	import com.comsol.model.util.*

	persistent SolverIndex;
	if isempty(SolverIndex)
		SolverIndex = 2;
	else
		SolverIndex = SolverIndex + 1;
	end

	new_tag = ['sol_' num2str(SolverIndex)];
	new_dset = ['dset' num2str(SolverIndex)];
	
	Old_Solver.detach;

	New_Solver = Model.sol.create(new_tag);

	New_Solver.study('std1');
	New_Solver.feature.create('st1', 'StudyStep');
	New_Solver.feature('st1').set('study', 'std1');
	New_Solver.feature('st1').set('studystep', 'time');
	New_Solver.feature.create('v1', 'Variables');
	New_Solver.feature('v1').set('control', 'time');
	New_Solver.feature.create('t1', 'Time');
	New_Solver.feature('t1').set('tlist', dt);
	New_Solver.feature('t1').set('plot', 'off');
	New_Solver.feature('t1').set('plotfreq', 'tout');
	New_Solver.feature('t1').set('probesel', 'all');
	New_Solver.feature('t1').set('probes', {});
	New_Solver.feature('t1').set('probefreq', 'tsteps');
	New_Solver.feature('t1').set('atolglobalmethod', 'scaled');
	New_Solver.feature('t1').set('atolglobal', 0.0010);
	New_Solver.feature('t1').set('maxorder', 2);
	New_Solver.feature('t1').set('control', 'time');
	New_Solver.feature('t1').feature.create('fc1', 'FullyCoupled');
	New_Solver.feature('t1').feature('fc1').set('jtech', 'once');
	New_Solver.feature('t1').feature('fc1').set('maxiter', 5);
	New_Solver.feature('t1').feature.create('d1', 'Direct');
	New_Solver.feature('t1').feature('d1').set('linsolver', 'pardiso');
	New_Solver.feature('t1').feature('fc1').set('linsolver', 'd1');
	New_Solver.feature('t1').feature('fc1').set('jtech', 'once');
	New_Solver.feature('t1').feature('fc1').set('maxiter', 5);
	New_Solver.feature('t1').feature.remove('fcDef');
	New_Solver.attach('std1');
	New_Solver.feature('v1').set('control', 'user');
	New_Solver.feature('v1').set('initmethod', 'sol');
	New_Solver.feature('v1').set('initsol',  Old_Solver.tag);
	New_Solver.feature('v1').set('solnum', 'last');
	
	Model.result('pg').set('data', new_dset);
	
	% Alte Solver löschen
	if SolverIndex > 2
		Model.sol.remove(['sol_' num2str(SolverIndex - 2)]);
	end
end

