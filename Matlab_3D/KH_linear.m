clc;
diary off;
if exist('logfile.txt', 'file')
	delete('logfile.txt');
end
diary('logfile.txt');

import com.comsol.model.*
import com.comsol.model.util.*

%% Parameter für das Modell
Tv = 3133;
v = 0.05 * 1e3; % [mm/s]

Pwidth = 4;
Pthickness = 3;
Plength = 10;

%% Koordinaten für die Speicherung
resolution = 1e-2; % [mm]
range_x = 0:resolution:Plength;
range_y = 0;
range_z = 0:-resolution:-1.5;

[XX, YY, ZZ] = meshgrid(range_x, range_y, range_z);
coords = [XX(:)'; YY(:)'; ZZ(:)'];


%% Zeit- und Ortsschritte festlegen

steps = 40;
distance = 2; % [mm]
dx_last = 2e-3;
cc = [steps, -steps^2; 1, -2*steps] \ [distance; dx_last];
KH_x = 2 + cc(1) * (1:steps) - cc(2) * (1:steps).^2; % [mm]

dt = diff(KH_x) ./ v;
dt(end + 1) = dx_last/v;

KH_y = zeros(size(KH_x));
%plot(KH_x, KH_y, 'o-');

%% Eventuelle Modelle entfernen
ModelUtil.clear;
ModelUtil.remove('Model');
ModelUtil.showProgress(false);

model = ModelUtil.create('Model');
model.modelPath('C:/Daten/Julius_FEM/Matlab_3D');
model.name('KH_linear.mph');

model.modelNode.create('mod1');

geometry = model.geom.create('geom1', 3);
geometry.lengthUnit('mm');

model.mesh.create('mesh1', 'geom1');
model.physics.create('ht', 'HeatTransfer', 'geom1');

model.study.create('std1');
model.study('std1').feature.create('time', 'Transient');
model.study('std1').feature('time').activate('ht', true);

% Keyholeposition festlegen
model.param.set('Lx', sprintf('%f [mm]', KH_x(1)));
model.param.set('Ly', sprintf('%f [mm]', KH_y(1)));
model.param.set('phi', '0 [°]');

%% Geometrie erzeugen
model.geom('geom1').feature('fin').set('repairtol', '1.0E-4');
% Blech
geometry.feature.create('blk1', 'Block');
geometry.feature('blk1').set('pos', [0, -Pwidth/2, -Pthickness]);
geometry.feature('blk1').set('size', [Plength, Pwidth, Pthickness]);
% Keyhole
load('KH_geom_metric.mat');
createKeyhole(model, geometry, KH_geom_metric);

%% Material zuweisen
initMaterial(model);

%% Randbedingungen setzen
% Keyhole Innenraum
model.physics('ht').feature.create('init2', 'init', 3);
model.physics('ht').feature('init2').selection.named('KH_Domain');
model.physics('ht').feature('init2').set('T', 1, Tv);
model.physics('ht').feature('init2').name('KH_Temp');
% Keyhole-Rand
model.physics('ht').feature.create('temp1', 'TemperatureBoundary', 2);
model.physics('ht').feature('temp1').selection.named('KH_Bounds');
model.physics('ht').feature('temp1').set('T0', 1, Tv);
model.physics('ht').feature('temp1').name('KH_Rand');

%% Mesh erzeugen
model.mesh('mesh1').feature.create('ftet1', 'FreeTet');
model.mesh('mesh1').feature('size').set('custom', 'on');
model.mesh('mesh1').feature('size').set('hmax', '3');
model.mesh('mesh1').feature('size').set('hmin', '0.28');
model.mesh('mesh1').feature('size').set('hcurve', '1.3'); % Kurvenradius
model.mesh('mesh1').feature('size').set('hgrad', '1.48'); % Maximale Wachstumsrate
model.mesh('mesh1').run;

%% Mesh plotten

stats = mphmeshstats(model);
fprintf('The mesh consists of %d elements. (%d edges)\n', stats.numelem(2), stats.numelem(1));

subplot(2, 1, 1);
mphmesh(model);
drawnow;

input('Generated Mesh. Enter to continue...');

alltime = tic;

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


i = 1; % Loop-runrolling für die erste Iteration

%% Zeitmessung starten
curtime = tic;

%% Modell lösen
ModelUtil.showProgress(true);
Solver.runAll;
model.result('pg').set('data', 'dset1');

%% Temperaturfeld Plotten
h1 = subplot(2, 1, 2);
mphplot(model, 'pg', 'rangenum', 1);
drawnow;

%% Schnitt speichern
saveSection(model, i, coords);

%% Fortschritt
itertime = toc(curtime);
remaining = (length(KH_x) - i) * itertime;
fprintf('Progress: %2d/%2d, %4.1f minutes remaining (%s).\n', i, length(KH_x), remaining/60,  datestr(now + remaining/86400, 'HH:MM:SS'));

%Next 3 lines of code are intended to stop the subplots from shrinking 
%while using colorbar, standard bug in matlab.
ax1 = get(h1,'position'); % Save the position as ax

%% GIF, erster Frame
filename = '../Ergebnisse/animation.gif';
frame = getframe(gcf);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
%%%%%%%%%%%%%%

clear getnextSolver;

for i=2:length(KH_x)
	
	curtime = tic;
	
	%% Zweiten Solver erzeugen
	Solver = getNextSolver(model, Solver, dt(i));

	%% Geometrie updaten
	model.param.set('Lx', KH_x(i));
	model.param.set('Ly', KH_y(i));
	
	model.geom('geom1').run;
	model.mesh('mesh1').run;
	
	stats = mphmeshstats(model);
	fprintf('The mesh consists of %d elements. (%d edges)\n', stats.numelem(2), stats.numelem(1));

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
    
    %% Schnitt speichern
	saveSection(model, i, coords);
	
	%% GIF Animation erzeugen
	frame = getframe(gcf);
	im = frame2im(frame);
	[imind,cm] = rgb2ind(im,256);

	imwrite(imind, cm, filename,'gif','WriteMode','append');
	%%%%%%%%%%%%%%%%%%%%
	
    thistime = toc(curtime);
    fprintf('Iterationsdauer: %.1f Minuten\n', thistime/60);
	itertime = 0.85 * itertime + 0.15 * thistime;
	remaining = (length(KH_x) - i) * itertime;
	fprintf('Progress: %2d/%2d, %4.1f minutes remaining (%s).\n', i, length(KH_x), remaining/60,  datestr(now + remaining/86400, 'HH:MM:SS'));
end

clearvars h i Tv Solver
 
toc(alltime)

%% Daten speichern
mphsave(model, ['E:/Team_H/FEM_Ergebnisse/' char(model.name)]);

range_x = 3.5:1e-2:4.5;
range_y = -0.5:1e-2:0.5;
range_z = -1:1e-2:0;

[XX, YY, ZZ] = meshgrid(range_x, range_y, range_z);
coords = [XX(:)'; YY(:)'; ZZ(:)'];

Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', coords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');  %#ok

coords = [XX(:)' - 4; YY(:)'; ZZ(:)'];  %#ok
save('../Ergebnisse/FinalTemps.mat', 'Temps', 'coords');

exit

