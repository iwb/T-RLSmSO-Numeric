import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Daten\Julius_FEM\Matlab_3D');

model.modelNode.create('mod1');

geo = createKeyhole(model, Apex, Radius);

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
