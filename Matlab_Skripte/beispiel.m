import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Daten\Julius_FEM\Matlab_3D');

model.modelNode.create('mod1');

geo = model.geom.create('geom1', 3);
model.geom('geom1').lengthUnit('mm');
model.geom('geom1').feature.create('blk1', 'Block');
model.geom('geom1').feature.create('cyl1', 'Cylinder');
model.geom('geom1').feature.create('cone1', 'Cone');
model.geom('geom1').feature('blk1').set('pos', {'0' '-10' '0'});
model.geom('geom1').feature('blk1').set('size', {'60' '20' '3'});
model.geom('geom1').feature('cyl1').set('r', '0.1');
model.geom('geom1').feature('cyl1').set('pos', {'3' '0' '2.5'});
model.geom('geom1').feature('cyl1').set('h', '0.5');
model.geom('geom1').feature('cone1').set('axis', {'0' '0' '-1'});
model.geom('geom1').feature('cone1').set('r', '0.1');
model.geom('geom1').feature('cone1').set('specifytop', 'radius');
model.geom('geom1').feature('cone1').set('rtop', '0');
model.geom('geom1').feature('cone1').set('pos', {'3' '0' '2.5'});
model.geom('geom1').feature('cone1').set('h', '0.4');
model.geom('geom1').run;

model.selection.create('sel1', 'Explicit');
model.selection('sel1').set([2 3]);
model.selection('sel1').name('Keyhole_Domain');
model.selection('sel1').name('Explicit 1');

model.physics.create('ht', 'HeatTransfer', 'geom1');
model.physics('ht').feature.create('init2', 'init', 3);
model.physics('ht').feature('init2').selection.named('sel1');
model.physics('ht').feature.create('temp1', 'TemperatureBoundary', 2);
model.physics('ht').feature('temp1').selection.set([6 7 8 10 12 13 14 15]);

model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').feature.create('ftet1', 'FreeTet');

model.physics('ht').feature('init2').set('T', '2000');
model.physics('ht').feature('temp1').set('T0', '2000');

model.mesh('mesh1').run;

model.study.create('std1');
model.study('std1').feature.create('time', 'Transient');
