%function runTask(config)

clc;
diary off;
addpath('../Keyhole');
addpath('./debugging');

config = initConfig;

output_path = '../Ergebnisse/';

logPath = [output_path 'diary.log'];
gifPath = [output_path 'animation.gif'];
sectionPath = [output_path 'Section_%02d.mat'];
timeStepMphPath = [output_path 'Model_%02d.mph'];
poolPath = [output_path 'Pool.mat'];
timesPath = [output_path 'Iteration_Times.mat'];
workspacePath = [output_path 'workspace.mat'];

if (config.sim.saveVideo && ~config.sim.showPlot)
	error('To save the video, you must enable the plot!');
end

if exist(logPath, 'file')
	inp = input('Old diary found. Overwrite? (y/n)  ', 's');
	if inp ~= 'j' && inp ~= 'y'
		fprintf('Calculation canceled.\n');
		return;
	end
	delete(logPath);
end
diary(logPath);

import com.comsol.model.*
import com.comsol.model.util.*

%% Koordinaten f�r die Sections
if (config.sim.saveSections)
	resolution = 10e-6; % [m]
	range_x = single(0 : resolution : config.dis.SampleLength);
	range_y = single(linspace(-2e-4, 2e-4, 9));
	range_z = single(0 : -resolution : -1.5e-3);
	
	[XX, YY, ZZ] = meshgrid(range_x, range_y, range_z);
	sectionCoords = [XX(:)'; YY(:)'; ZZ(:)'];
	
	save([output_path 'Section_Coords.mat'], 'range_x', 'range_y', 'range_z');
	clear resolution range_x range_y range_z XX YY ZZ
end

%% Koordinaten f�r den Pool
if (config.sim.savePool)
	resolution = 200e-6; % [m]
	range_x = (0 : resolution : config.dis.SampleLength);
	range_y = (-config.dis.SampleWidth/3 : resolution : config.dis.SampleWidth/3);
	range_z = (0 : -resolution : -config.dis.SampleThickness);
	
	[YY, XX, ZZ] = meshgrid(range_y, range_x, range_z);
	poolCoords = [XX(:)'; YY(:)'; ZZ(:)'];
	poolPageSize = [size(range_x, 2), size(range_y, 2)];
	poolPages = size(range_z, 2);
	poolCoords = reshape(poolCoords, 3, prod(poolPageSize), poolPages);
	
	% Pool initialisieren
	Pool = false(size(XX));
	ProjectedPool = false(size(range_y, 2), size(range_z, 2));
	
	clear resolution range_x range_y range_z XX YY ZZ
end

%% Zeit- und Ortsschritte festlegen
[KH_x, KH_y, phiArray, speedArray, dt, Sensor_x, Sensor_y, Cyl_x] = createLinearTrajectory(config);

save([output_path 'KH+Info.mat'], 'KH_x', 'KH_y', 'dt', 'config');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Anzahl der Iterationen definieren
iterations = 50; %config.sim.TimeSteps;

keyholetime	= zeros(iterations, 1);
meshtime	= zeros(iterations, 1);
solvertime	= zeros(iterations, 1);
pooltime    = zeros(iterations, 1);
energy      = zeros(iterations, 1);

i = 1; % Loop-runrolling f�r die erste Iteration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Eventuelle Modelle entfernen
ModelUtil.clear;
ModelUtil.remove('Model');
ModelUtil.showProgress(false);

model = ModelUtil.create('Model');
%model.modelPath('C:/Daten/Julius_FEM/Matlab_3D');
model.name('Final_Model.mph');

model.modelNode.create('mod1');

geometry = model.geom.create('geom1', 3);
geometry.lengthUnit('m');

model.mesh.create('mesh1', 'geom1');
model.physics.create('ht', 'HeatTransfer', 'geom1');

model.study.create('std1');
model.study('std1').feature.create('time', 'Transient');
model.study('std1').feature('time').activate('ht', true);

% Keyholeposition festlegen
model.param.set('Lx', KH_x(1)); % [m]
model.param.set('Ly', KH_y(1)); % [m]
model.param.set('phi', sprintf('%.12e [rad]', phiArray(1)));
model.param.set('Cyl_x', sprintf('%.12e [m]', Cyl_x(1)));
model.param.set('Cyl_r', sprintf('%.12e [m]', (config.osz.Amplitude + config.las.WaistSize) * 1.5));

%% Geometrie erzeugen
model.geom('geom1').feature('fin').set('repairtol', '1.0E-5');
% Blech
geometry.feature.create('blk1', 'Block');
geometry.feature('blk1').set('pos', [0, -config.dis.SampleWidth/2, -config.dis.SampleThickness]);
geometry.feature('blk1').set('size', [config.dis.SampleLength, config.dis.SampleWidth, config.dis.SampleThickness]);

% Fein gemeshter Zylinder
% model.geom('geom1').feature.create('cyl1', 'Cylinder');
% model.geom('geom1').feature('cyl1').set('pos', {'Cyl_x' '0' '-Cyl_h'});
% model.geom('geom1').feature('cyl1').set('h', 'Cyl_h');
% model.geom('geom1').feature('cyl1').set('r', 'Cyl_r');

cone = geometry.feature.create('roicone', 'ECone');
cone.set('axis', [0, 0, -1]);
cone.set('semiaxes', {'Cyl_r', 'Cyl_r'});
cone.set('pos', {'Cyl_x' '0' '0'});
cone.set('h', 'Cyl_h');
cone.set('displ', [0, 0]);
cone.set('rat', 0.5);
cone.set('rot', 0);

%% Keyhole berechnen und in die Geometrie einf�gen
fprintf('Calculating KH ...\n');
keyholestart = tic;

clear updateKeyhole;
KH_depth = createKeyhole(model, geometry, speedArray(1), config);

keyholetime(i) = toc(keyholestart);
fprintf('done. (%0.1f sec)\n', keyholetime(i));

%% Material zuweisen
initMaterial(model, config);

%% Randbedingungen setzen

model.physics('ht').feature('init1').set('T', 1, sprintf('%d[K]', config.mat.AmbientTemperature));

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

%% Mesh erzeugen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Meshing ... ');
meshstart = tic;

ModelUtil.showProgress(config.sim.showComsolProgress);
createMesh_fine(model);

meshtime(i) = toc(meshstart);
fprintf('done. (%0.1f sec)\n', meshtime(i));

%% Mesh plotten
stats = mphmeshstats(model);
fprintf('The mesh consists of %d elements. (%d edges)\n', stats.numelem(2), stats.numelem(1));

if (config.sim.confirmMesh)
    subplot(2, 1, 1);
    mphmesh(model);
    drawnow;
    input('Generated Mesh. Enter to continue...');
end

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Erste Iteration beginnt    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Zeitmessung starten
iterstart = tic;

fprintf('\nCurrent Time: %s\n', datestr(now));
fprintf('\nStarting iteration %2d/%2d, Timestep: %0.2fms\n', i, iterations, dt(i)*1e3);

tweet(sprintf('Starting calculation (%2d/%2d timesteps, %3d elements)', iterations, config.sim.TimeSteps, stats.numelem(2)));

%% Modell l�sen
fprintf('Solving model ... ');
solverstart = tic;
Solver.runAll;
solvertime(i) = toc(solverstart);
fprintf('done. (%0.1f min)\n', solvertime(i)/60);

model.result('pg').set('data', 'dset1');

%% Volumenintegration erstellen f�r die interne Energie
model.result.numerical.create('int1', 'IntVolume');
model.result.numerical('int1').setIndex('looplevelinput', 'last', 0);
model.result.numerical('int1').selection.all;
model.result.numerical('int1').set('expr', 'material.rho * material.Cp * (T - 293.15[K])');
energy(i) = model.result.numerical('int1').getReal();

%% Temperaturfeld Plotten
if (config.sim.showPlot)
	h1 = subplot(2, 1, 2);
	mphplot(model, 'pg', 'rangenum', 1);
	drawnow;
end

%% MPH speichern
if (config.sim.saveTimeStepMph)
	fprintf('Saving mph file ... ');
	flushDiary(logPath);
	mphsave(model, sprintf(timeStepMphPath, i));
	fprintf('done.\n');
	flushDiary(logPath);
end

%% Schnitt speichern
if (config.sim.saveSections)
	saveSection(model, i, sectionCoords, sectionPath);
end

%% Pool kumulieren
fprintf('Saving pool ... ');
poolstart = tic;
if (config.sim.savePool)
	for z = 1 : poolPages
		Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', poolCoords(:, :, z), 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
		Temps = reshape(Temps, poolPageSize);
		Pool(:, :, z) = Pool(:, :, z) | (Temps > config.mat.MeltingTemperature);
		ProjectedPool = ProjectedPool | squeeze(any(Pool, 1));
	end
end
pooltime(i) = toc(poolstart);
fprintf('done. (%0.1f min)\n', pooltime(i)/60);

%% Fortschritt
itertime = toc(iterstart);
remaining = (iterations - i) * itertime;
progress_msg = sprintf('Iteration %2d/%2d was finished in %.1f minutes\nApproximately %4.1f minutes remaining (%s).\n\n', i, iterations, itertime/60, remaining/60,  datestr(now + remaining/86400, 'yyyy-mm-dd HH:MM:SS'));
fprintf(progress_msg);
tweet(progress_msg);

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

%% Flush diary
flushDiary(logPath);

%% Convergence counter
% If this reaches a definied threshold, the calculation is finished. It is
% reset when the projected pool changes and incremented when it doesn't.
PoolConvergence = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Alle weiteren Iterationen    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% �ber die Schritte iterieren
for i=2 : iterations
	
	iterstart = tic;
	
	fprintf('Current Time: %s\n\n', datestr(now));
	fprintf('Starting iteration %2d/%2d, Timestep: %0.2fms\n', i, iterations, dt(i)*1e3);
	
	%% Zweiten Solver erzeugen
	Solver = getNextSolver(model, Solver, dt(i));
	
	%% Temperatur an der Stelle des n�chsten KH messen
% 	SensorCoords(3, :) = linspace(0, KH_depth, 5);
% 	SensorCoords(1, :) = Sensor_x(i);
% 	SensorCoords(2, :) = Sensor_y(i);
% 	SensorTemps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i-1)], 'coord', SensorCoords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
 	
	%% Geometrie updaten
	model.param.set('Lx', KH_x(i));
	model.param.set('Ly', KH_y(i));
	model.param.set('phi', sprintf('%.12e [rad]', phiArray(i)));
	model.param.set('Cyl_x', sprintf('%.12e [m]', Cyl_x(i)));
	
	fprintf('Calculating KH ...\n');
	keyholestart = tic;	
    
    if (true)
        plotVorlauf
    end
    
	% mean(SensorTemps)
	KH_depth = updateKeyhole(model, geometry, speedArray(i), config.mat.AmbientTemperature, config);
	keyholetime(i) = toc(keyholestart);
	fprintf('done. (%0.1f sec)\n', keyholetime(i));
	
	
	%% Mesh updaten

	[meshtime(i), stats] = updateMesh(model);
	
	%% Mesh plotten
	if (config.sim.showPlot)
		subplot(2, 1, 1);
		mphmesh(model);
		drawnow;
	end
	
	%% Modell L�sen
	fprintf('Solving model ... ');
	solverstart = tic;
	Solver.runAll;
	solvertime(i) = toc(solverstart);
	fprintf('done. (%0.1f min)\n', solvertime(i)/60);
	
    %% Volumenintegration aktualisieren
    
    model.result.numerical('int1').set('data', ['dset' num2str(i)]);
    % Workaround
    model.result.numerical('int1').selection.named('KH_Domain');
    model.result.numerical('int1').selection.all;
    energy(i) = model.result.numerical('int1').getReal();
	
	%% Temperaturfeld Plotten
	if (config.sim.showPlot)
		subplot(2, 1, 2);
		mphplot(model, 'pg', 'rangenum', 1);
		set(gca,'position',ax1); % Manually setting this holds the position with colorbar
		drawnow;
	end
	
	%% MPH speichern
	if (config.sim.saveTimeStepMph)
		fprintf('Saving mph file ... ');
		flushDiary(logPath);
		mphsave(model, sprintf(timeStepMphPath, i));
		fprintf('done.\n');
		flushDiary(logPath);
	end

	%% Schnitt speichern
	if (config.sim.saveSections)
		saveSection(model, i, sectionCoords, sectionPath);
	end
	
	%% Pool kumulieren
	if (config.sim.savePool)
		fprintf('Saving pool ... ');
		poolstart = tic;
		for z = 1 : poolPages
			Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', poolCoords(:, :, z), 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
			Temps = reshape(Temps, poolPageSize);
			Pool(:, :, z) = Pool(:, :, z) | (Temps > config.mat.MeltingTemperature);
		end
		
		projection = squeeze(any(Pool, 1));
		if any(any(projection & ~ProjectedPool)) % If new points are added
			PoolConvergence = 0;	% Reset the counter
		else
			PoolConvergence = PoolConvergence + 1;
		end
		ProjectedPool = ProjectedPool | projection;
		
		pooltime(i) = toc(poolstart);
		fprintf('done. (%0.1f min)\n', pooltime(i)/60);
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
    progress_msg = sprintf('Iteration %2d/%2d was finished in %.1f minutes\n', i, iterations, thistime/60);
    
    if (i < iterations)
        itertime = 0.8 * itertime + 0.2 * thistime;
        remaining = (iterations - i) * itertime;
        progress_msg = [progress_msg sprintf('Approximately %4.1f minutes remaining (%s).\n\n', remaining/60,  datestr(now + remaining/86400, 'yyyy-mm-dd HH:MM:SS'))]; %#ok<AGROW>
    end
    
    fprintf(progress_msg);
    tweet(progress_msg);
    
	%% Flush diary
	flushDiary(logPath);
	
	if PoolConvergence >= config.sim.PoolConvergenceThreshold
		fprintf('The Pool convergence threshold is reached :-)\n');
		%break;
	end
end

%% Schleife beendet, Zeit ausgeben
clearvars Solver

alltime = toc(allstart);
progress_msg = sprintf('\nOverall time taken: %dh%02.0fm\n', floor(alltime / 3600), rem(alltime, 3600)/60);
fprintf(progress_msg);
tweet(progress_msg);

%% Eingebrachte Leistung in jeder Iteration berechnen
addedEnergy = diff([0; energy]);
iterpower = addedEnergy ./ dt(1:iterations)';

%% Daten speichern
fprintf('Saving iteration times ... ');
flushDiary(logPath);
save(timesPath, 'keyholetime', 'meshtime', 'solvertime', 'pooltime', 'energy', 'iterpower');
fprintf('done.\n');
flushDiary(logPath);

if (config.sim.saveMph)
	fprintf('Saving mph file ... ');
	flushDiary(logPath);
	mphsave(model, [output_path char(model.name)]);
	fprintf('done.\n');
	flushDiary(logPath);
end

%% Pool speichern
if (config.sim.savePool)
	fprintf('Saving pool ... ');
	flushDiary(logPath);
	poolCoords = reshape(poolCoords, 3, prod(poolPageSize) * poolPages);
	save(poolPath, 'Pool', 'poolCoords');
	fprintf('done.\n');
	flushDiary(logPath);
end

%% Endtemperaturen speichern
if (config.sim.saveFinalTemps)
	fprintf('Saving final temps ... ');
	flushDiary(logPath);
	resolution = 40e-6; % [m]
	range_x = 0 : resolution : 5e-3;
	range_y = -2e-3 : resolution : 2e-3;
	range_z = 0: -resolution : -2e-3;
	
	[XX, YY, ZZ] = meshgrid(range_x, range_y, range_z);
	finalCoords = [XX(:)'; YY(:)'; ZZ(:)'];
	
	FinalTemps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', finalCoords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
	
	save([output_path 'FinalTemps.mat'], 'FinalTemps', 'finalCoords');
	fprintf('done.\n');
	flushDiary(logPath);
	clear finalCoords resolution range_x range_y range_z XX YY ZZ
end

% Damit man den Workspace speichern kann, m�ssen die COMSOL-Objekte
% gel�scht werden.
clear geometry cone ans Solver model;
save(workspacePath);

progress_msg = sprintf('\nWorkspace saved, calculation finished.\n');
fprintf(progress_msg);
tweet(progress_msg);

diary off
%% Auf der Workstation die COMSOL-Lizenz freigeben
if (strcmp(getenv('COMPUTERNAME'), 'WAP09CELSIUS4'))
	exit
end

if (strcmp(getenv('COMPUTERNAME'), 'POONS'))
	exit
end

%end
