function [ New_Solver ] = getNextSolverMultigrid(model, Old_Solver, dt, varargin)
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

    if (nargin == 4)
        SolverIndex = varargin{1};
        return;
    end

    new_tag = ['sol_' num2str(SolverIndex)];
    new_dset = ['dset' num2str(SolverIndex)];

    Old_Solver.detach;
    
    New_Solver = model.sol.create(new_tag);
    New_Solver.study('std1');
    New_Solver.feature.create('st1', 'StudyStep');
    New_Solver.feature.create('v1', 'Variables');
    New_Solver.feature.create('t1', 'Time');
    New_Solver.feature('t1').feature.create('fc1', 'FullyCoupled');
    New_Solver.feature('t1').feature.create('i1', 'Iterative');
    New_Solver.feature('t1').feature('i1').feature.create('mg1', 'Multigrid');
    New_Solver.feature('t1').feature('i1').feature('mg1').feature('pr').feature.create('sl1', 'SORLine');
    New_Solver.feature('t1').feature('i1').feature('mg1').feature('po').feature.create('sl1', 'SORLine');
    New_Solver.feature('t1').feature('i1').feature('mg1').feature('cs').feature.create('d1', 'Direct');
    New_Solver.feature('t1').feature.remove('fcDef');

    New_Solver.feature('st1').name('Compile Equations: Time Dependent {time}');
    New_Solver.feature('st1').set('studystep', 'time');
    New_Solver.feature('v1').set('solnum', 'last');
    New_Solver.feature('v1').set('initmethod', 'sol');
    New_Solver.feature('v1').set('initsol', Old_Solver.tag);
    New_Solver.feature('t1').set('maxorder', '2');
    New_Solver.feature('t1').set('atolglobal', '0.001');
    New_Solver.feature('t1').set('initialstepbdf', '0.001');
    New_Solver.feature('t1').set('solfile', false);
    New_Solver.feature('t1').set('rtol', '0.001');
    New_Solver.feature('t1').set('tlist', '4.4E-4');
    New_Solver.feature('t1').set('control', 'time');
    New_Solver.feature('t1').set('bwinitstepfrac', '0.001');
    New_Solver.feature('t1').set('tstepsbdf', 'strict');
    New_Solver.feature('t1').feature('fc1').set('jtech', 'once');
    New_Solver.feature('t1').feature('fc1').set('damp', '0.9');
    New_Solver.feature('t1').feature('fc1').set('maxiter', '5');
    New_Solver.feature('t1').feature('i1').set('rhob', '20');
    New_Solver.feature('t1').feature('i1').feature('mg1').set('mcasegen', 'manual');
    New_Solver.feature('t1').feature('i1').feature('mg1').feature('pr').feature('sl1').set('relax', '0.3');
    New_Solver.feature('t1').feature('i1').feature('mg1').feature('pr').feature('sl1').set('linerelax', '0.4');
    New_Solver.feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('seconditer', '2');
    New_Solver.feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('relax', '0.5');
    New_Solver.feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('linerelax', '0.4');
    New_Solver.feature('t1').feature('i1').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
    
    % Multigrids wieder benutzen
    New_Solver.feature('t1').feature('i1').feature('mg1').set('mcaseuse', {'mgl1' 'mgl2' 'mgl3'}); 
    New_Solver.feature('t1').feature('i1').feature('mg1').set('mcaseassem', {'mgl1' 'mgl2' 'mgl3'});

    model.result('pg').set('data', new_dset);

    % Neuen Zeitschritt zuweisen
    model.study('std1').feature('time').set('tlist', dt);

    % Alte Solver löschen
    if SolverIndex > 3
        % Speicher sparen
        old_dset = ['dset' num2str(SolverIndex - 3)];
        model.result.dataset.remove(old_dset);
        model.sol.remove(['sol_' num2str(SolverIndex - 2)]);
    end
end

