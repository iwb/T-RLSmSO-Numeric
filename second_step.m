function out = model
%
% second_step.m
%
% Model exported on Oct 8 2013, 18:17 by COMSOL 4.3.1.161.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Daten\Julius_FEM');

model.name('Mein MATLAB Test');

model.modelNode.create('Modelltest');

model.geom.create('geom1', 2);
model.geom('geom1').lengthUnit('mm');
model.geom('geom1').feature.create('r1', 'Rectangle');
model.geom('geom1').feature.create('r2', 'Rectangle');
model.geom('geom1').feature('r1').name('Probe');
model.geom('geom1').feature('r1').set('size', {'40' '10'});
model.geom('geom1').feature('r2').name('Keyhole');
model.geom('geom1').feature('r2').set('size', {'1' '4'});
model.geom('geom1').feature('r2').set('pos', {'15' '6'});
model.geom('geom1').run;

model.material.create('mat1');
model.material('mat1').info.create('DIN');
model.material('mat1').info.create('Composition');
model.material('mat1').propertyGroup('def').func.create('dL', 'Piecewise');
model.material('mat1').propertyGroup('def').func.create('k', 'Piecewise');
model.material('mat1').propertyGroup('def').func.create('alpha', 'Piecewise');
model.material('mat1').propertyGroup('def').func.create('C', 'Piecewise');
model.material('mat1').propertyGroup('def').func.create('rho', 'Piecewise');
model.material('mat1').propertyGroup('def').func.create('TD', 'Piecewise');

model.physics.create('ht', 'HeatTransfer', 'geom1');
model.physics('ht').feature.create('KH_Temp', 'init', 2);
model.physics('ht').feature('KH_Temp').selection.set([2]);
model.physics('ht').feature.create('KH_Rand_Temp', 'TemperatureBoundary', 1);
model.physics('ht').feature('KH_Rand_Temp').selection.set([4 5 7]);

model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').feature.create('ftri1', 'FreeTri');

model.view('view1').axis.set('ymin', '-16.387062072753906');
model.view('view1').axis.set('ymax', '27.31087875366211');
model.view('view1').axis.set('xmin', '-3.3230133056640625');
model.view('view1').axis.set('xmax', '46.46858596801758');

model.material('mat1').name('X10NiCrMoTiB1515 (DIN 1.4970) [solid]');
model.material('mat1').info('DIN').body('X 10 Ni Cr Mo Ti B 15-15');
model.material('mat1').info('Composition').body('bal Fe, (14.5-15.5) Cr, (15-16) Ni, (1.05-1.25) Mo, (1.6-2) Mn, (0.35-0.55) Ti, (0.08-0.12) C, (0.25-0.45) Si, 0.03 P max, 0.015 S max (wt%)');
model.material('mat1').propertyGroup('def').func('dL').set('pieces', {'293.0' '1273.0' '-0.004001145+1.123311E-5*T^1+9.137522E-9*T^2-2.96589E-12*T^3'});
model.material('mat1').propertyGroup('def').func('dL').set('arg', 'T');
model.material('mat1').propertyGroup('def').func('k').set('pieces', {'293.0' '1273.0' '9.200508+0.0132224*T^1+6.943989E-6*T^2-7.160077E-9*T^3+1.702977E-12*T^4'});
model.material('mat1').propertyGroup('def').func('k').set('arg', 'T');
model.material('mat1').propertyGroup('def').func('alpha').set('pieces', {'293.0' '1273.0' '1.378384E-5+8.008135E-9*T^1-2.829525E-12*T^2'});
model.material('mat1').propertyGroup('def').func('alpha').set('arg', 'T');
model.material('mat1').propertyGroup('def').func('C').set('pieces', {'293.0' '1273.0' '330.7133+0.8038326*T^1-0.001260275*T^2+1.03842E-6*T^3-3.146145E-10*T^4'});
model.material('mat1').propertyGroup('def').func('C').set('arg', 'T');
model.material('mat1').propertyGroup('def').func('rho').set('pieces', {'293.0' '1273.0' '8067.331-0.2796353*T^1-2.019394E-4*T^2+7.199288E-8*T^3'});
model.material('mat1').propertyGroup('def').func('rho').set('arg', 'T');
model.material('mat1').propertyGroup('def').func('TD').set('pieces', {'293.0' '1273.0' '3.354831E-6-1.551308E-9*T^1+9.499459E-12*T^2-8.71403E-15*T^3+2.630357E-18*T^4'});
model.material('mat1').propertyGroup('def').func('TD').set('arg', 'T');
model.material('mat1').propertyGroup('def').set('dL', 'dL(T[1/K])-dL(Tempref[1/K])');
model.material('mat1').propertyGroup('def').set('thermalconductivity', {'k(T[1/K])[W/(m*K)]' '0' '0' '0' 'k(T[1/K])[W/(m*K)]' '0' '0' '0' 'k(T[1/K])[W/(m*K)]'});
model.material('mat1').propertyGroup('def').set('thermalexpansioncoefficient', {'alpha(T[1/K])[1/K]+(Tempref-293[K])/(T-Tempref)*(alpha(T[1/K])[1/K]-alpha(Tempref[1/K])[1/K])' '0' '0' '0' 'alpha(T[1/K])[1/K]+(Tempref-293[K])/(T-Tempref)*(alpha(T[1/K])[1/K]-alpha(Tempref[1/K])[1/K])' '0' '0' '0' 'alpha(T[1/K])[1/K]+(Tempref-293[K])/(T-Tempref)*(alpha(T[1/K])[1/K]-alpha(Tempref[1/K])[1/K])'});
model.material('mat1').propertyGroup('def').set('heatcapacity', 'C(T[1/K])[J/(kg*K)]');
model.material('mat1').propertyGroup('def').set('density', 'rho(T[1/K])[kg/m^3]');
model.material('mat1').propertyGroup('def').set('TD', 'TD(T[1/K])[m^2/s]');
model.material('mat1').propertyGroup('def').addInput('temperature');
model.material('mat1').propertyGroup('def').addInput('strainreferencetemperature');

model.physics('ht').feature('KH_Temp').set('T', '2000');
model.physics('ht').feature('KH_Temp').name(['W' native2unicode(hex2dec('00e4'), 'Cp1252') 'rmequelle']);
model.physics('ht').feature('KH_Rand_Temp').set('T0', '2000');

model.mesh('mesh1').feature('size').set('hgrad', '1.2');
model.mesh('mesh1').feature('size').set('hmax', '3');
model.mesh('mesh1').run;

model.study.create('std1');
model.study('std1').feature.create('time', 'Transient');
model.study('std1').feature.create('time2', 'Transient');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').feature.create('st1', 'StudyStep');
model.sol('sol1').feature.create('v1', 'Variables');
model.sol('sol1').feature.create('t1', 'Time');
model.sol('sol1').feature('t1').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').feature.create('d1', 'Direct');
model.sol('sol1').feature('t1').feature.remove('fcDef');
model.sol('sol1').feature.create('st2', 'StudyStep');
model.sol('sol1').feature.create('v2', 'Variables');
model.sol('sol1').feature.create('t2', 'Time');
model.sol('sol1').feature('t2').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t2').feature.create('d1', 'Direct');
model.sol('sol1').feature('t2').feature.remove('fcDef');

model.result.create('pg1', 'PlotGroup2D');
model.result('pg1').feature.create('surf1', 'Surface');
model.result.create('pg2', 'PlotGroup2D');
model.result('pg2').feature.create('con1', 'Contour');
model.result('pg2').feature.create('arws1', 'ArrowSurface');

model.study('std1').feature('time').name('StepA');
model.study('std1').feature('time').set('tlist', '0.1');
model.study('std1').feature('time').set('plot', 'on');

model.study('std1').feature('time2').name('StepB');
model.study('std1').feature('time2').set('initmethod', 'sol');
model.study('std1').feature('time2').set('tlist', '0.1');
model.study('std1').feature('time').set('plot', 'on');
model.study('std1').feature('time2').set('useinitsol', 'on');
model.study('std1').feature('time2').set('initstudy', 'std1');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('st1').name('Compile Equations: Time Dependent');
model.sol('sol1').feature('st1').set('studystep', 'time');
model.sol('sol1').feature('v1').set('control', 'time');
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').set('tlist', '0.1');
model.sol('sol1').feature('t1').set('maxorder', '2');
model.sol('sol1').feature('t1').set('plot', 'on');
model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t1').feature('fc1').set('maxiter', '5');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('st2').name('Compile Equations: Time Dependent 2 (2)');
model.sol('sol1').feature('st2').set('studystep', 'time2');
model.sol('sol1').feature('v2').set('notsolmethod', 'sol');
model.sol('sol1').feature('v2').set('initsol', 'sol1');
model.sol('sol1').feature('v2').set('notsol', 'sol1');
model.sol('sol1').feature('v2').set('control', 'time2');
model.sol('sol1').feature('v2').set('initmethod', 'sol');
model.sol('sol1').feature('t2').set('control', 'time2');
model.sol('sol1').feature('t2').set('tlist', '0.1');
model.sol('sol1').feature('t2').set('maxorder', '2');
model.sol('sol1').feature('t2').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t2').feature('fc1').set('maxiter', '5');
model.sol('sol1').feature('t2').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').runAll;

model.result('pg1').name('Temperature');
model.result('pg1').feature('surf1').name('Surface');
model.result('pg1').feature('surf1').set('colortable', 'ThermalLight');
model.result('pg1').feature('surf1').set('data', 'dset1');
model.result('pg1').feature('surf1').set('looplevel', {'2'});
model.result('pg2').name('Isothermal contours');
model.result('pg2').feature('con1').name('Contour');
model.result('pg2').feature('con1').set('colortable', 'ThermalLight');
model.result('pg2').feature('arws1').name('Arrow surface');
model.result('pg2').feature('arws1').set('color', 'gray');

out = model;
