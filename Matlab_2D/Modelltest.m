clear all;

import com.comsol.model.*
import com.comsol.model.util.*

%% Parameter für das Modell
Tv = 2000;
Keyhole_Positions = linspace(5, 50, 12);

%% Eventuelle Modelle entfernen
ModelUtil.clear;
ModelUtil.remove('Model');
ModelUtil.showProgress(false);

%% Modell erstellen
Model = ModelUtil.create('Model');

Model.modelPath('C:\Daten\Julius_FEM\Matlab_test');
Model.name('basic_step_2.mph');

Model.modelNode.create('mod1');
Model.geom.create('geom1', 2);
Model.geom('geom1').lengthUnit('mm');

Model.mesh.create('mesh1', 'geom1');
Model.physics.create('ht', 'HeatTransfer', 'geom1');

Model.study.create('std1');
Model.study('std1').feature.create('time', 'Transient');
Model.study('std1').feature('time').activate('ht', true);

%% Geometrie erzeugen
% Probe
Probe_rect = Model.geom('geom1').feature.create('r1', 'Rectangle');
Probe_rect.set('size', [60, 10]);
Probe_rect.name('Probe');
% Keyhole
KH_rect = Model.geom('geom1').feature.create('r2', 'Rectangle');
KH_rect.set('size', [1, 4]);
KH_rect.set('pos', [Keyhole_Positions(1), 6]);
KH_rect.name('Keyhole');

Model.geom('geom1').run;

%% Material zuweisen
init_Material(Model);

%% Randbedingungen setzen
% Keyhole Innenraum
Model.physics('ht').feature.create('init2', 'init', 2);
Model.physics('ht').feature('init2').selection.set(2);
Model.physics('ht').feature('init2').set('T', 1, num2str(Tv));
Model.physics('ht').feature('init2').name('KH_Temp');
% Keyhole-Rand
Model.physics('ht').feature.create('temp1', 'TemperatureBoundary', 1);
Model.physics('ht').feature('temp1').selection.set([4 5 7]);
Model.physics('ht').feature('temp1').set('T0', 1, num2str(Tv));
Model.physics('ht').feature('temp1').name('KH_Rand');

%% Mesh erzeugen
Model.mesh('mesh1').feature('size').set('custom', 'on');
Model.mesh('mesh1').feature('size').set('hmax', '1');
Model.mesh('mesh1').feature.create('ftri1', 'FreeTri');
Model.mesh('mesh1').feature('ftri1').selection.geom('geom1');
Model.mesh('mesh1').feature('size').set('hmax', '3.3');
Model.mesh('mesh1').feature('size').set('hgrad', '1.3');
Model.mesh('mesh1').run;

%% Mesh plotten
subplot(2, 1, 1);
mphmesh(Model);
drawnow;

input('Generated Mesh. Enter to continue...');

%% Solver konfigurieren
Model.study('std1').feature('time').set('tlist', '0.1');
Solver = init_Solver(Model);

%% Anzeige erstellen
Model.result.create('pg', 'PlotGroup2D');
Model.result('pg').name('Temperature');
Model.result('pg').set('data', 'dset1');
Model.result('pg').set('oldanalysistype', 'noneavailable');
Model.result('pg').set('t', 0.1);
Model.result('pg').feature.create('surf1', 'Surface');
Model.result('pg').feature('surf1').name('Surface');
Model.result('pg').feature('surf1').set('colortable', 'ThermalLight');
Model.result('pg').feature('surf1').set('data', 'parent');

%% Modell lösen
ModelUtil.showProgress(true);
Solver.runAll;
Model.result('pg').set('data', 'dset1');

%% Temperaturfeld Plotten
h1 = subplot(2, 1, 2);
mphplot(Model, 'pg', 'rangenum', 1);
drawnow;

%Next 3 lines of code are intended to stop the subplots from shrinking 
%while using colorbar, standard bug in matlab.
ax1 = get(h1,'position'); % Save the position as ax

for i=2:length(Keyhole_Positions)
	
	%% Zweiten Solver erzeugen
	Solver = getNextSolver(Model, Solver);

	%% Geometrie updaten
	Model.geom('geom1').feature('r2').set('pos', [Keyhole_Positions(i), 6]);
	Model.geom('geom1').run;
	Model.mesh('mesh1').run;

	%% Mesh plotten
	subplot(2, 1, 1);
	mphmesh(Model);
	drawnow;

	%% Modell Lösen
	Solver.runAll;
	
	%% Temperaturfeld Plotten
	subplot(2, 1, 2);
	mphplot(Model, 'pg', 'rangenum', 1);
	set(gca,'position',ax1); % Manually setting this holds the position with colorbar
	drawnow;
	
	%% GIF Animnation erzeugn
	
end

clearvars h i Tv Solver Probe_rect KH_rect Keyhole_Positions
 
 
 
