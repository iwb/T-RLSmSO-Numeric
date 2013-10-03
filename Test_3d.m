function out = model
%
% Test_3d.m
%
% Model exported on Oct 3 2013, 19:49 by COMSOL 4.3.1.161.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Daten\Julius_FEM');

model.name('3D_Test_1.mph');

model.modelNode.create('mod1');

model.geom.create('geom1', 3);
model.geom('geom1').lengthUnit('mm');
model.geom('geom1').geomRep('comsol');
model.geom('geom1').feature.create('blk1', 'Block');
model.geom('geom1').feature.create('cone1', 'Cone');
model.geom('geom1').feature('blk1').set('size', {'40' '10' '3'});
model.geom('geom1').feature('blk1').set('pos', {'0' '-5' '0'});
model.geom('geom1').feature('cone1').set('pos', {'3' '0' '3'});
model.geom('geom1').feature('cone1').set('axis', {'0' '0' '-1'});
model.geom('geom1').feature('cone1').set('h', '1.2');
model.geom('geom1').feature('cone1').set('rtop', '0');
model.geom('geom1').feature('cone1').set('r', '0.1');
model.geom('geom1').feature('cone1').set('specifytop', 'radius');
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
model.physics('ht').feature.create('temp1', 'TemperatureBoundary', 2);
model.physics('ht').feature('temp1').selection.set([6 8 9 10]);
model.physics('ht').feature.create('init2', 'init', 3);
model.physics('ht').feature('init2').selection.set([2]);

model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').feature.create('ftet1', 'FreeTet');

model.result.table.create('evl3', 'Table');

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

model.physics('ht').feature('temp1').set('T0', '2000');
model.physics('ht').feature('init2').set('T', '2000');

model.mesh('mesh1').feature('size').set('hgrad', '1.3');
model.mesh('mesh1').feature('size').set('hcurve', '0.2');
model.mesh('mesh1').feature('size').set('hmax', '2');
model.mesh('mesh1').feature('size').set('hmin', '0.1');
model.mesh('mesh1').run;

model.result.table('evl3').name('Evaluation 3D');
model.result.table('evl3').comments('Interactive 3D values');

model.study.create('std1');
model.study('std1').feature.create('time', 'Transient');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').feature.create('st1', 'StudyStep');
model.sol('sol1').feature.create('v1', 'Variables');
model.sol('sol1').feature.create('t1', 'Time');
model.sol('sol1').feature('t1').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').feature.create('i1', 'Iterative');
model.sol('sol1').feature('t1').feature('i1').feature.create('mg1', 'Multigrid');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').feature.create('sl1', 'SORLine');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature.create('sl1', 'SORLine');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('cs').feature.create('d1', 'Direct');
model.sol('sol1').feature('t1').feature.remove('fcDef');

model.result.create('pg1', 'PlotGroup3D');
model.result('pg1').feature.create('surf1', 'Surface');
model.result.create('pg2', 'PlotGroup3D');
model.result('pg2').feature.create('iso1', 'Isosurface');
model.result('pg2').feature.create('arwv1', 'ArrowVolume');
model.result.export.create('anim1', 'Animation');

model.study('std1').feature('time').set('tlist', 'range(0,0.1,0.2)');
model.study('std1').feature('time').set('plot', 'on');
model.study('std1').feature('time').set('probefreq', 'tout');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('st1').name('Compile Equations: Time Dependent');
model.sol('sol1').feature('st1').set('studystep', 'time');
model.sol('sol1').feature('v1').set('control', 'time');
model.sol('sol1').feature('t1').set('probefreq', 'tout');
model.sol('sol1').feature('t1').set('tlist', 'range(0,0.1,0.2)');
model.sol('sol1').feature('t1').set('plot', 'on');
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').set('maxorder', '2');
model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t1').feature('fc1').set('maxiter', '5');
model.sol('sol1').feature('t1').feature('i1').set('rhob', '20');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').feature('sl1').set('relax', '0.3');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').feature('sl1').set('linerelax', '0.4');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('relax', '0.5');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('linerelax', '0.4');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('seconditer', '2');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').runAll;

model.result('pg1').name('Temperature');
model.result('pg1').feature('surf1').name('Surface');
model.result('pg1').feature('surf1').set('colortable', 'ThermalLight');
model.result('pg2').name('Isothermal contours');
model.result('pg2').set('looplevel', {'1'});
model.result('pg2').feature('iso1').name('Isosurface');
model.result('pg2').feature('iso1').set('colortable', 'ThermalLight');
model.result('pg2').feature('iso1').set('number', '10');
model.result('pg2').feature('arwv1').name('Arrow volume');
model.result('pg2').feature('arwv1').set('color', 'gray');
model.result('pg2').feature('arwv1').set('arrowlength', 'logarithmic');
model.result.export('anim1').set('giffilename', 'C:\Users\Julius\Desktop\3d_test.gif');
model.result.export('anim1').set('height', '480');
model.result.export('anim1').set('width', '640');
model.result.export('anim1').set('lockratio', 'off');
model.result.export('anim1').set('resolution', '96');
model.result.export('anim1').set('size', 'manual');
model.result.export('anim1').set('antialias', 'off');
model.result.export('anim1').set('title', 'on');
model.result.export('anim1').set('legend', 'on');
model.result.export('anim1').set('logo', 'on');
model.result.export('anim1').set('options', 'off');
model.result.export('anim1').set('fontsize', '9');
model.result.export('anim1').set('customcolor', [1 1 1]);
model.result.export('anim1').set('background', 'color');
model.result.export('anim1').set('axisorientation', 'on');
model.result.export('anim1').set('grid', 'on');
model.result.export('anim1').set('axes', 'on');

out = model;
