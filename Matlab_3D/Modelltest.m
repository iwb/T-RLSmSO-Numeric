clear all;

import com.comsol.model.*
import com.comsol.model.util.*

%% Parameter für das Modell
Tv = 2000;
t = 0:0.5:7;
KH_x = 5 + 0.1*t - cos(t);
KH_y = sin(t);

%% Eventuelle Modelle entfernen
ModelUtil.clear;
ModelUtil.remove('Model');
ModelUtil.showProgress(false);

%% Modell erstellen
model = ModelUtil.create('Model');
model.param.set('xpos', KH_x(1));
model.param.set('ypos', KH_y(1));

model.modelPath('C:\Daten\Julius_FEM\Matlab_test');
model.name('basic_step_2.mph');

model.modelNode.create('mod1');
model.geom.create('geom1', 3);
model.geom('geom1').lengthUnit('mm');

model.mesh.create('mesh1', 'geom1');
model.physics.create('ht', 'HeatTransfer', 'geom1');

model.study.create('std1');
model.study('std1').feature.create('time', 'Transient');
model.study('std1').feature('time').activate('ht', true);

%% Geometrie erzeugen
% Probe
Probe = model.geom('geom1').feature.create('blk1', 'Block');
model.geom('geom1').feature('blk1').set('pos', [0, -10, 0]);
model.geom('geom1').feature('blk1').set('size', [60, 20, 3]);
Probe.name('Probe');

% Keyhole
model.geom('geom1').feature.create('cyl1', 'Cylinder');
model.geom('geom1').feature('cyl1').set('r', 0.1);
model.geom('geom1').feature('cyl1').set('pos', {'xpos', 'ypos', '2.5'});
model.geom('geom1').feature('cyl1').set('h', '0.5');

model.geom('geom1').feature.create('cone1', 'Cone');
model.geom('geom1').feature('cone1').set('axis', [0, 0, -1]);
model.geom('geom1').feature('cone1').set('r', '0.1');
model.geom('geom1').feature('cone1').set('specifytop', 'radius');
model.geom('geom1').feature('cone1').set('rtop', '0');
model.geom('geom1').feature('cone1').set('pos', {'xpos', 'ypos', '2.5'});
model.geom('geom1').feature('cone1').set('h', '0.4');

model.geom('geom1').run;

KH_domain = model.selection.create('KH_Domain');
KH_domain.geom(3);
KH_domain.set([2 3]);
KH_domain.name('Keyhole_Domain');

KH_boundary = model.selection.create('KH_Boundary', 'Adjacent');
KH_boundary.set('input', {'KH_Domain'});
KH_boundary.name('Keyhole_Boundary');

%% Material zuweisen
initMaterial(model);

%% Randbedingungen setzen
% Keyhole Innenraum
model.physics('ht').feature.create('init2', 'init', 3);
model.physics('ht').feature('init2').selection.named('KH_Domain');
model.physics('ht').feature('init2').set('T', 1, num2str(Tv));
model.physics('ht').feature('init2').name('KH_Temp');
% Keyhole-Rand
model.physics('ht').feature.create('temp1', 'TemperatureBoundary', 2);
model.physics('ht').feature('temp1').selection.named('KH_Boundary');
model.physics('ht').feature('temp1').set('T0', 1, num2str(Tv));
model.physics('ht').feature('temp1').name('KH_Rand');

%% Mesh erzeugen
model.mesh('mesh1').feature.create('ftet1', 'FreeTet');
model.mesh('mesh1').feature('size').set('custom', 'on');
model.mesh('mesh1').feature('size').set('hmax', '3');
model.mesh('mesh1').feature('size').set('hcurve', '0.3');
model.mesh('mesh1').feature('size').set('hgrad', '1.4');
model.mesh('mesh1').run;

%% Mesh plotten
subplot(2, 1, 1);
mphmesh(model);
drawnow;

input('Generated Mesh. Enter to continue...');

%% Solver konfigurieren
model.study('std1').feature('time').set('tlist', '0.1');
Solver = initSolver(model);

%% Anzeige erstellen
model.result.create('pg', 'PlotGroup3D');
model.result('pg').name('Temperature');
model.result('pg').set('data', 'dset1');
model.result('pg').feature.create('surf1', 'Surface');
model.result('pg').feature('surf1').name('Surface');
model.result('pg').feature('surf1').set('colortable', 'ThermalLight');
model.result('pg').feature('surf1').set('data', 'parent');
model.result('pg').set('t', 0.1);

%% Modell lösen
ModelUtil.showProgress(true);
Solver.runAll;
model.result('pg').set('data', 'dset1');

%% Temperaturfeld Plotten
h1 = subplot(2, 1, 2);
mphplot(model, 'pg', 'rangenum', 1);
drawnow;

%Next 3 lines of code are intended to stop the subplots from shrinking 
%while using colorbar, standard bug in matlab.
ax1 = get(h1,'position'); % Save the position as ax

for i=2:length(KH_x)
	
	%% Zweiten Solver erzeugen
	Solver = getNextSolver(model, Solver);

	%% Geometrie updaten
	model.param.set('xpos', KH_x(i));
	model.param.set('ypos', KH_y(i));
	
	model.geom('geom1').run;
	model.mesh('mesh1').run;

	%% Mesh plotten
	subplot(2, 1, 1);
	mphmesh(model);
	drawnow;

	%% Modell Lösen
	Solver.runAll;
	
	%% Temperaturfeld Plotten
	subplot(2, 1, 2);
	mphplot(model, 'pg', 'rangenum', 1);
	set(gca,'position',ax1); % Manually setting this holds the position with colorbar
	drawnow;
	
	%% GIF Animnation erzeugn
	break
end

clearvars h i Tv Solver Probe_rect KH_rect Keyhole_Positions
 
 
 
