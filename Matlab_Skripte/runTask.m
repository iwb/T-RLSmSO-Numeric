%function runTask(config)

clc;
diary off;

config = initConfig;

output_path = './Ergebnisse/';

logPath = [output_path 'diary.log'];
gifPath = [output_path 'animation.gif'];
sectionPath = [output_path 'Section_%02d.mat'];
poolPath = 'Pool.mat';

if exist(logPath, 'file')
	delete(logPath);
end
diary(logPath);

import com.comsol.model.*
import com.comsol.model.util.*

%% Parameter f�r das Modell

%% Koordinaten f�r die Sections
if (config.sim.saveSections)
	resolution = 5e-3; % [mm]
	range_x = 0 : resolution : config.dis.SampleLength;	
	range_y = 0;
	range_z = 0 : -resolution : -1.5;
	
	[XX, YY, ZZ] = meshgrid(range_x, range_y, range_z);
	sectionCoords = [XX(:)'; YY(:)'; ZZ(:)'];
	
	save([output_path 'Section_Coords.mat'], 'range_x', 'range_y', 'range_z');
	clear resolution range_x range_y range_z XX YY ZZ
end

%% Koordinaten f�r den Pool
if (config.sim.savePool)
	resolution = 100e-3; % [mm]
	range_x = 0 : resolution : config.dis.SampleLength;
	range_y = -config.dis.SampleWidth/2 : resolution : config.dis.SampleWidth/2;
	range_z = 0 : -resolution : -config.dis.SampleThickness;
	
	[XX, YY, ZZ] = meshgrid(range_x, range_y, range_z);
	poolCoords = [XX(:)'; YY(:)'; ZZ(:)'];
	clear resolution range_x range_y range_z XX YY ZZ
end

%% Zeit- und Ortsschritte festlegen
[KH_x, KH_y, phiArray, speedArray, dt, Sensor_x, Sensor_y] = createTrajectory(config);

save([output_path 'KH_Coords.mat'], 'KH_x', 'KH_y', 'dt');

%% Eventuelle Modelle entfernen
ModelUtil.clear;
ModelUtil.remove('Model');
ModelUtil.showProgress(false);

model = ModelUtil.create('Model');
%model.modelPath('C:/Daten/Julius_FEM/Matlab_3D');
model.name('KH_linear.mph');

model.modelNode.create('mod1');

geometry = model.geom.create('geom1', 3);
geometry.lengthUnit('m');

model.mesh.create('mesh1', 'geom1');
model.physics.create('ht', 'HeatTransfer', 'geom1');

model.study.create('std1');
model.study('std1').feature.create('time', 'Transient');
model.study('std1').feature('time').activate('ht', true);

% Keyholeposition festlegen
model.param.set('Lx', KH_x(1));
model.param.set('Ly', KH_y(1));
model.param.set('phi', sprintf('%.12e [rad]', phiArray(1)));

%% Geometrie erzeugen
model.geom('geom1').feature('fin').set('repairtol', '1.0E-6');
% Blech
geometry.feature.create('blk1', 'Block');
geometry.feature('blk1').set('pos', [0, -config.dis.SampleWidth/2, -config.dis.SampleThickness]);
geometry.feature('blk1').set('size', [config.dis.SampleLength, config.dis.SampleWidth, config.dis.SampleThickness]);
% Keyhole
clear updateKeyhole;
KH_depth = createKeyhole(model, geometry, speedArray(1), config);

%% Material zuweisen
initMaterial(model, config);

%% Randbedingungen setzen
% Keyhole Innenraum
model.physics('ht').feature.create('init2', 'init', 3);
model.physics('ht').feature('init2').selection.named('KH_Domain');
model.physics('ht').feature('init2').set('T', 1, config.mat.VaporTemperature);
model.physics('ht').feature('init2').name('KH_Temp');
% Keyhole-Rand
model.physics('ht').feature.create('temp1', 'TemperatureBoundary', 2);
model.physics('ht').feature('temp1').selection.named('KH_Bounds');
model.physics('ht').feature('temp1').set('T0', 1, config.mat.VaporTemperature);
model.physics('ht').feature('temp1').name('KH_Rand');

%% Mesh erzeugen
model.mesh('mesh1').feature.create('ftet1', 'FreeTet');
model.mesh('mesh1').feature('size').set('custom', 'on');
model.mesh('mesh1').feature('size').set('hmax', '1 [mm]');
model.mesh('mesh1').feature('size').set('hmin', '10 [�m]');
model.mesh('mesh1').feature('size').set('hgrad', '1.4'); % Maximale Wachstumsrate
model.mesh('mesh1').feature('size').set('hcurve', '0.8'); % Kurvenradius, kleiner = feiner
model.mesh('mesh1').feature('size').set('hnarrow', '0.6'); % Aufl�sung schmaler Regionen. gr��er = feiner


ModelUtil.showProgress(config.sim.showComsolProgress);
model.mesh('mesh1').run;

%% Mesh plotten

stats = mphmeshstats(model);
fprintf('The mesh consists of %d elements. (%d edges)\n', stats.numelem(2), stats.numelem(1));

subplot(2, 1, 1);
mphmesh(model);
drawnow;

input('Generated Mesh. Enter to continue...');

allstart = tic;

%% Ersten Solver konfigurieren
model.study('std1').feature('time').set('tlist', dt(1));
Solver = initSolver(model, dt(1));

%% Anzeige erstellen
model.result.create('pg', 'PlotGroup3D');
model.result('pg').name('Temperature');
model.result('pg').set('data', 'dset1');
model.result('pg').feature.create('surf1', 'Surface');
model.result('pg').feature('surf1').name('Surface');
model.result('pg').feature('surf1').set('colortable', 'Thermal');
model.result('pg').feature('surf1').set('data', 'parent');
model.result('pg').set('t', 0.1);

%% Pool initialisieren
if (config.sim.savePool)
	Pool = false(1, size(poolCoords, 2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Erste Iteration beginnt    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Zeitmessung starten
iterstart = tic;
i = 1; % Loop-runrolling f�r die erste Iteration

fprintf('\nStarting iteration %2d/%2d, Timestep: %0.2fms\n', i, length(KH_x), dt(i)*1e3);

%% Modell l�sen
Solver.runAll;
model.result('pg').set('data', 'dset1');

%% Temperaturfeld Plotten
if (config.sim.showPlot)
	h1 = subplot(2, 1, 2);
	mphplot(model, 'pg', 'rangenum', 1);
	drawnow;
end

%% Schnitt speichern
if (config.sim.saveSections)
	saveSection(model, i, sectionCoords, sectionPath);
end

%% Pool kumulieren
if (config.sim.savePool)
	Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', poolCoords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
	Pool = Pool | (Temps > config.mat.MeltingTemperature);
end

%% Fortschritt
itertime = toc(iterstart);
remaining = (length(KH_x) - i) * itertime;
fprintf('Iteration %2d/%2d was finished in %.1f minutes\n', i, length(KH_x), itertime/60);
fprintf('Approximately %4.1f minutes remaining (%s).\n\n', remaining/60,  datestr(now + remaining/86400, 'HH:MM:SS'));


%% GIF, erster Frame
if (config.sim.saveVideo)
% Next line of code are intended to stop the subplots from shrinking
% while using colorbar, standard bug in matlab.
	ax1 = get(h1,'position'); % Save the position as ax
	
	frame = getframe(gcf);
	im = frame2im(frame);
	[imind,cm] = rgb2ind(im, 256);
	imwrite(imind, cm, gifPath, 'gif', 'Loopcount', inf);
end

%% Wichtig, da sonst die Nummern der Solver nicht mehr stimmen!
clear getnextSolver;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Alle wieteren Iterationen    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% �ber die Schritte iterieren
for i=2:length(KH_x)
	
	iterstart = tic;
	
	fprintf('Starting iteration %2d/%2d, Timestep: %0.2fms\n', i, length(KH_x), dt(i)*1e3);
	
	%% Zweiten Solver erzeugen
	Solver = getNextSolver(model, Solver, dt(i));
    
    %% Temperatur an der Stelle des n�chsten KH messen
    SensorCoords(3, :) = linspace(0, KH_depth, 5);
    SensorCoords(1, :) = Sensor_x(i);
    SensorCoords(2, :) = Sensor_y(i);
    SensorTemps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i-1)], 'coord', SensorCoords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
    
	%% Geometrie updaten
	model.param.set('Lx', KH_x(i));
	model.param.set('Ly', KH_y(i));
	model.param.set('phi', sprintf('%.12e [rad]', phiArray(i)));
	
	KH_depth = updateKeyhole(model, geometry, speedArray(i), mean(SensorTemps), config);
	
	model.geom('geom1').run;
	model.mesh('mesh1').run;
	
	stats = mphmeshstats(model);
	fprintf('The mesh consists of %d elements. (%d edges)\n', stats.numelem(2), stats.numelem(1));
	
	%% Mesh plotten
	if (config.sim.showPlot)
		subplot(2, 1, 1);
		mphmesh(model);
		drawnow;
	end
	
	%% Modell L�sen
	Solver.runAll;
	
	%% Temperaturfeld Plotten
	if (config.sim.showPlot)
		subplot(2, 1, 2);
		mphplot(model, 'pg', 'rangenum', 1);
		set(gca,'position',ax1); % Manually setting this holds the position with colorbar
		drawnow;
	end
	
	%% Schnitt speichern
	if (config.sim.saveSections)
		saveSection(model, i, sectionCoords, sectionPath);
	end
	
	%% Pool kumulieren
	if (config.sim.savePool)
		Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', poolCoords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
		Pool = Pool | (Temps > config.mat.MeltingTemperature);
	end
	
	%% GIF Animation erzeugen
	if (config.sim.saveVideo)
		frame = getframe(gcf);
		im = frame2im(frame);
		[imind,cm] = rgb2ind(im,256);
		imwrite(imind, cm, gifPath, 'gif', 'WriteMode', 'append');
	end
	
	%% Fortschritt anzeigen
	thistime = toc(iterstart);
	fprintf('Iteration %2d/%2d was finished in %.1f minutes\n', i, length(KH_x), thistime/60);
	if (i < length(KH_x))
		itertime = 0.8 * itertime + 0.2 * thistime;
		remaining = (length(KH_x) - i) * itertime;
		fprintf('Approximately %4.1f minutes remaining (%s).\n\n', remaining/60,  datestr(now + remaining/86400, 'HH:MM:SS'));
	end
end

clearvars Solver

alltime = toc(allstart);
fprintf('\nOverall time taken: %dh%02.0fm\n', floor(alltime / 3600), rem(alltime, 3600)/60);


%% Daten speichern
if (config.sim.saveMph)
	mphsave(model, [output_path char(model.name)]);
end

% Pool speichern
if (config.sim.savePool)
	save(poolPath, 'Pool', 'poolCoords');
end

if (config.sim.saveFinalTemps)
	resolution = 50e-3; % [mm]
	range_x = 0 : resolution :Plength;
	range_y = -0.5 : resolution : 0.5;
	range_z = 0: -resolution :-1.5;
	
	[XX, YY, ZZ] = meshgrid(range_x, range_y, range_z);
	finalCoords = [XX(:)'; YY(:)'; ZZ(:)'];
	
	FinalTemps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', finalCoords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
	
	save([output_path 'FinalTemps.mat'], 'FinalTemps', 'finalCoords');
end

diary off

% Auf der Workstation die COMSOL-Lizenz freigeben
if (strcmp(getenv('COMPUTERNAME'), 'WAP09CELSIUS4'))
	exit
end

%end
