clear all;
clc;

import com.comsol.model.*
import com.comsol.model.util.*

%% Parameter für das Modell
Tv = 2000;

%% Eventuelle Modelle entfernen
ModelUtil.clear;
ModelUtil.remove('Model');
ModelUtil.showProgress(false);

%% Modell erstellen
model = ModelUtil.create('Model');

model.modelPath('C:\Daten\Julius_FEM\Matlab_test');
model.name('basic_step_2.mph');

model.modelNode.create('mod1');
model.geom.create('geom1', 2);
model.mesh.create('mesh1', 'geom1');
model.physics.create('ht', 'HeatTransfer', 'geom1');

model.study.create('std1');
model.study('std1').feature.create('time', 'Transient');
model.study('std1').feature('time').activate('ht', true);

%% Geometrie erzeugen
model.geom('geom1').lengthUnit('mm');
model.geom('geom1').feature.create('r1', 'Rectangle');
model.geom('geom1').feature('r1').setIndex('size', '100', 0);
model.geom('geom1').feature('r1').setIndex('size', '10', 1);
model.geom('geom1').feature('r1').name('Probe');
model.geom('geom1').run('r1');
model.geom('geom1').feature.create('r2', 'Rectangle');
model.geom('geom1').feature('r2').setIndex('size', '4', 1);
model.geom('geom1').feature('r2').setIndex('pos', '10', 0);
model.geom('geom1').feature('r2').setIndex('pos', '6', 1);
model.geom('geom1').feature('r2').name('Keyhole');
model.geom('geom1').runAll;
model.geom('geom1').run;

%% Material zuweisen
init_material(model);

%% Randbedingungen setzen
% Keyhole Innenraum
model.physics('ht').feature.create('init2', 'init', 2);
model.physics('ht').feature('init2').selection.set(2);
model.physics('ht').feature('init2').set('T', 1, num2str(Tv));
model.physics('ht').feature('init2').name('KH_Temp');
% Keyhole-Rand
model.physics('ht').feature.create('temp1', 'TemperatureBoundary', 1);
model.physics('ht').feature('temp1').selection.set([4 5 7]);
model.physics('ht').feature('temp1').set('T0', 1, num2str(Tv));
model.physics('ht').feature('temp1').name('KH_Rand');

%% Mesh erzeugen
model.mesh('mesh1').feature.create('size1', 'Size');
model.mesh('mesh1').feature('size').set('custom', 'on');
model.mesh('mesh1').feature.remove('size1');
model.mesh('mesh1').feature('size').set('hmax', '1');
model.mesh('mesh1').run;
model.mesh('mesh1').run;
model.mesh('mesh1').run;
model.mesh('mesh1').feature.create('ftri1', 'FreeTri');
model.mesh('mesh1').feature('ftri1').selection.geom('geom1');
model.mesh('mesh1').feature.duplicate('size1', 'size');
model.mesh('mesh1').feature.remove('size1');
model.mesh('mesh1').run('ftri1');
model.mesh('mesh1').feature('size').set('hmax', '3');
model.mesh('mesh1').run;
model.mesh('mesh1').feature('size').set('hmax', '3.2');
model.mesh('mesh1').run;
model.mesh('mesh1').feature('size').set('hmax', '3');
model.mesh('mesh1').feature('size').set('hgrad', '1.2');
model.mesh('mesh1').run;

model.study('std1').feature('time').set('tlist', '0.1');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').feature.create('st1', 'StudyStep');
model.sol('sol1').feature('st1').set('study', 'std1');
model.sol('sol1').feature('st1').set('studystep', 'time');
model.sol('sol1').feature.create('v1', 'Variables');
model.sol('sol1').feature('v1').set('control', 'time');
model.sol('sol1').feature.create('t1', 'Time');
model.sol('sol1').feature('t1').set('tlist', '0.1');
model.sol('sol1').feature('t1').set('plot', 'off');
model.sol('sol1').feature('t1').set('plotfreq', 'tout');
model.sol('sol1').feature('t1').set('probesel', 'all');
model.sol('sol1').feature('t1').set('probes', {});
model.sol('sol1').feature('t1').set('probefreq', 'tsteps');
model.sol('sol1').feature('t1').set('atolglobalmethod', 'scaled');
model.sol('sol1').feature('t1').set('atolglobal', 0.0010);
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t1').feature('fc1').set('maxiter', 5);
model.sol('sol1').feature('t1').feature.create('d1', 'Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('fc1').set('linsolver', 'd1');
model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t1').feature('fc1').set('maxiter', 5);
model.sol('sol1').feature('t1').feature.remove('fcDef');
model.sol('sol1').attach('std1');

model.result.create('pg1', 'PlotGroup2D');
model.result('pg1').name('Temperature');
model.result('pg1').set('data', 'dset1');
model.result('pg1').feature.create('surf1', 'Surface');
model.result('pg1').feature('surf1').name('Surface');
model.result('pg1').feature('surf1').set('colortable', 'ThermalLight');
model.result('pg1').feature('surf1').set('data', 'parent');


model.sol('sol1').runAll;

model.result('pg1').run;

model.name('basic.mph');

model.result('pg1').run;

model.sol('sol1').detach;
model.sol.create('sol2');
model.sol('sol2').study('std1');
model.sol('sol2').feature.create('st1', 'StudyStep');
model.sol('sol2').feature('st1').set('study', 'std1');
model.sol('sol2').feature('st1').set('studystep', 'time');
model.sol('sol2').feature.create('v1', 'Variables');
model.sol('sol2').feature('v1').set('control', 'time');
model.sol('sol2').feature.create('t1', 'Time');
model.sol('sol2').feature('t1').set('tlist', '0.1');
model.sol('sol2').feature('t1').set('plot', 'off');
model.sol('sol2').feature('t1').set('plotgroup', 'pg1');
model.sol('sol2').feature('t1').set('plotfreq', 'tout');
model.sol('sol2').feature('t1').set('probesel', 'all');
model.sol('sol2').feature('t1').set('probes', {});
model.sol('sol2').feature('t1').set('probefreq', 'tsteps');
model.sol('sol2').feature('t1').set('atolglobalmethod', 'scaled');
model.sol('sol2').feature('t1').set('atolglobal', 0.0010);
model.sol('sol2').feature('t1').set('maxorder', 2);
model.sol('sol2').feature('t1').set('control', 'time');
model.sol('sol2').feature('t1').feature.create('fc1', 'FullyCoupled');
model.sol('sol2').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol2').feature('t1').feature('fc1').set('maxiter', 5);
model.sol('sol2').feature('t1').feature.create('d1', 'Direct');
model.sol('sol2').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol2').feature('t1').feature('fc1').set('linsolver', 'd1');
model.sol('sol2').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol2').feature('t1').feature('fc1').set('maxiter', 5);
model.sol('sol2').feature('t1').feature.remove('fcDef');
model.sol('sol2').attach('std1');
model.sol('sol2').feature('v1').set('control', 'user');
model.sol('sol2').feature('v1').set('initmethod', 'sol');
model.sol('sol2').feature('v1').set('initsol', 'sol1');
model.sol('sol2').feature('v1').set('solnum', 'last');

model.geom('geom1').feature('r2').setIndex('pos', '15', 0);
model.geom('geom1').runAll;

model.result.create('pg2', 'PlotGroup2D');
model.result('pg2').name('Temperature 1');
model.result('pg2').set('data', 'dset2');
model.result('pg2').set('oldanalysistype', 'noneavailable');
model.result('pg2').set('t', 0);
model.result('pg2').set('data', 'dset2');
model.result('pg2').feature.create('surf1', 'Surface');
model.result('pg2').feature('surf1').name('Surface');
model.result('pg2').feature('surf1').set('colortable', 'ThermalLight');
model.result('pg2').feature('surf1').set('data', 'parent');

model.sol('sol2').runAll;

model.result('pg2').run;

mphplot(model, 'pg2', 'rangenum', 1);
