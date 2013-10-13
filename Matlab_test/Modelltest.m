clear all;
clc;

import com.comsol.model.*
import com.comsol.model.util.*

%% Parameter für das Modell
Tv = 2000;

ModelUtil.showProgress(false);
model = ModelUtil.create('Model');
model.modelPath('C:\Daten\Julius_FEM');
model.name('Mein MATLAB Test');

model.modelNode.create('Modelltest');

model.geom.create('geom1', 2);
model.geom('geom1').lengthUnit('mm');

%% Geometrie festlegen
% Probenblech
model.geom('geom1').feature.create('r1', 'Rectangle');
model.geom('geom1').feature('r1').name('Probe');
model.geom('geom1').feature('r1').set('size', {'40' '10'});

% Keyhole
KH_rect = model.geom('geom1').feature.create('r2', 'Rectangle');
KH_rect.name('Keyhole');
KH_rect.set('size', {'1' '4'});
KH_rect.set('pos', {'10' '6'});

% Geometrieerzeugung
model.geom('geom1').run;

%% Material festlegen
init_material(model);

%% Physik festlegen: Wärmeleitung
ht = model.physics.create('ht', 'HeatTransfer', 'geom1');

% Initialwert innerhalb des KH
ht.feature.create('KH_Temp', 'init', 2);
ht.feature('KH_Temp').selection.set(2);
ht.feature('KH_Temp').set('T', num2str(Tv));
ht.feature('KH_Temp').name('Wärmequelle');

% Randbedingung für den Rand des KH
ht.feature.create('KH_Rand_Temp', 'TemperatureBoundary', 1);
ht.feature('KH_Rand_Temp').selection.set([4 5 7]);
ht.feature('KH_Rand_Temp').set('T0', num2str(Tv));


%% Meshen
model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').feature.create('ftri1', 'FreeTri');
model.mesh('mesh1').feature('size').set('hgrad', '1.2');
model.mesh('mesh1').feature('size').set('hmax', '3');
model.mesh('mesh1').run;

%%Study
Study = model.study.create('std1');
StepA = Study.feature.create('time', 'Transient');
ModelUtil.showProgress(true);

%% Zeitschritt A
StepA.name('StepA');
StepA.set('tlist', '0.1');
StepA.set('plot', 'on');

Solver = model.sol.create('sol1');
Solver.study('std1');
Solver.attach('std1');
Solver.feature.create('st1', 'StudyStep');
Solver.feature.create('v1', 'Variables');
Solver.feature.create('t1', 'Time');
Solver.feature('t1').feature.create('fc1', 'FullyCoupled');
Solver.feature('t1').feature.create('d1', 'Direct');
Solver.feature('t1').feature.remove('fcDef');
Solver.feature.create('st2', 'StudyStep');
Solver.feature.create('v2', 'Variables');
Solver.feature.create('t2', 'Time');
Solver.feature('t2').feature.create('fc1', 'FullyCoupled');
Solver.feature('t2').feature.create('d1', 'Direct');
Solver.feature('t2').feature.remove('fcDef');

%% Ergebnisplot 1
model.result.create('pg1', 'PlotGroup2D');
model.result('pg1').feature.create('surf1', 'Surface');
model.result('pg1').name('Temperature');

%% Geometrie ändern
KH_rect.set('pos', {'15' '6'});
model.mesh('mesh1').run;

StepB = Study.feature.create('time2', 'Transient');
StepB.name('StepB');
StepB.name('StepB');
StepB.set('initmethod', 'sol');
StepB.set('tlist', '0.1');
StepB.set('plot', 'on');
StepB.set('useinitsol', 'on');
StepB.set('initstudy', 'std1');


Solver.attach('std1');
Solver.feature('st1').name('Compile Equations: Time Dependent');
Solver.feature('st1').set('studystep', 'time');
Solver.feature('v1').set('control', 'time');
Solver.feature('t1').set('control', 'time');
Solver.feature('t1').set('tlist', '0.1');
Solver.feature('t1').set('maxorder', '2');
Solver.feature('t1').set('plot', 'on');
Solver.feature('t1').feature('fc1').set('jtech', 'once');
Solver.feature('t1').feature('fc1').set('maxiter', '5');
Solver.feature('t1').feature('d1').set('linsolver', 'pardiso');
Solver.feature('st2').name('Compile Equations: Time Dependent 2 (2)');
Solver.feature('st2').set('studystep', 'time2');
Solver.feature('v2').set('notsolmethod', 'sol');
Solver.feature('v2').set('initsol', 'sol1');
Solver.feature('v2').set('notsol', 'sol1');
Solver.feature('v2').set('control', 'time2');
Solver.feature('v2').set('initmethod', 'sol');
Solver.feature('t2').set('control', 'time2');
Solver.feature('t2').set('tlist', '0.1');
Solver.feature('t2').set('maxorder', '2');
Solver.feature('t2').feature('fc1').set('jtech', 'once');
Solver.feature('t2').feature('fc1').set('maxiter', '5');
Solver.feature('t2').feature('d1').set('linsolver', 'pardiso');
Solver.runAll;

model.result('pg1').feature('surf1').name('Surface');
model.result('pg1').feature('surf1').set('colortable', 'Thermal');

mphplot(model, 'pg1', 'rangenum', 1);
