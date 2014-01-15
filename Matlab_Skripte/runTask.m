clc;

clear getnextSolver;
clear getnextSolverMultigrid;
clear updateKeyhole;

diary off;
addpath('../Keyhole');
addpath('./debugging');
addpath('../PP_Zylinderquelle');

config = initConfig;

output_path = '../Ergebnisse/';

logPath = [output_path 'diary.log'];
gifPath = [output_path 'animation.gif'];
figurePath = [output_path 'Figure_%03d.png'];
sectionPath = [output_path 'Section_%03d.mat'];
timeStepMphPath = [output_path 'Model_%03d.mph'];
poolPath = [output_path 'Pool.mat'];
poolCoordsPath = [output_path 'Pool.mat'];
timesPath = [output_path 'Iteration_Times.mat'];
workspacePath = [output_path 'workspace.mat'];

if (config.sim.saveVideo && ~config.sim.showPlot)
    error('To save the video, you must enable the plot!');
end

if exist(logPath, 'file')
    inp = input('Old diary found. Overwrite? (y/n)  ', 's');
    if any(inp ~= 'j') && any(inp ~= 'y')
        fprintf('Calculation canceled.\n');
        return;
    end
    delete(logPath);
end
diary(logPath);

import com.comsol.model.*
import com.comsol.model.util.*

%% Koordinaten für die Sections
if (config.sim.saveSections)
    resolution = 10e-6; % [m]
    range_x = single(0 : resolution : config.dis.SampleLength);
    range_y = single(linspace(-4e-4, 4e-4, 9));
    range_z = single(0 : -resolution : -1.2e-3);
    
    [XX, YY, ZZ] = meshgrid(range_x, range_y, range_z);
    sectionCoords = [XX(:)'; YY(:)'; ZZ(:)'];
    
    save([output_path 'Section_Coords.mat'], 'range_x', 'range_y', 'range_z');
    clear resolution range_x range_y range_z XX YY ZZ
end

%% Koordinaten für den Pool
if (config.sim.savePool)
    resolution = 15e-6; % [m]
    range_x = (0 : resolution : config.dis.SampleLength);
    range_y = (-config.dis.SampleWidth/4 : resolution : config.dis.SampleWidth/4);
    range_z = (0 : -resolution : -config.dis.SampleThickness);
    
    [YY, XX, ZZ] = meshgrid(range_y, range_x, range_z);
    poolCoords = [XX(:)'; YY(:)'; ZZ(:)'];
    poolPageSize = [size(range_x, 2), size(range_y, 2)];
    poolPages = size(range_z, 2);
    save(poolCoordsPath, 'range_x', 'range_y', 'range_z');
    poolCoords = reshape(poolCoords, 3, prod(poolPageSize), poolPages);
    
    % Pool initialisieren
    Pool = false(size(XX));
    ProjectedPool = false(size(range_y, 2), size(range_z, 2));
    
    clear resolution range_x range_y range_z XX YY ZZ
end

%% Zeit- und Ortsschritte festlegen
[KH_x, KH_y, phiArray, speedArray, dt, ~] = createTrajectory(config);

meanSpeed = 2*pi * config.osz.Frequency * config.osz.Amplitude;
kappa = config.mat.ThermalConductivity / (config.mat.Density * config.mat.HeatCapacity);
Pe = config.las.WaistSize / kappa * meanSpeed;
thermal_distance = kappa ./ meanSpeed;
step_distance = sqrt(sum(([KH_x(2) ; KH_y(2)] - [KH_x(1) ; KH_y(1)]).^2));

fprintf('Pe: %.1f, WEZ: %.1e, SW: %.1e\n', Pe, thermal_distance, step_distance);

save([output_path 'KH+Info.mat'], 'KH_x', 'KH_y', 'dt', 'config');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Anzahl der Iterationen definieren
iterations = config.dis.TimeSteps;

keyholetime	= zeros(iterations, 1);
meshtime	= zeros(iterations, 1);
solvertime	= zeros(iterations, 1);
pooltime    = zeros(iterations, 1);
energy      = zeros(iterations, 1);

i = 1; % Loop-runrolling für die erste Iteration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Eventuelle Modelle entfernen
ModelUtil.clear;
ModelUtil.remove('Model');
ModelUtil.showProgress(false);

model = ModelUtil.create('Model');
model.name('MATLAB_Model.mph');
model.author('Julius F. Heins');

model.modelNode.create('mod1');

model.geom.create('geom1', 3);
model.geom('geom1').lengthUnit('m');

model.mesh.create('mesh1', 'geom1');
model.physics.create('ht', 'HeatTransfer', 'geom1');

model.study.create('std1');
model.study('std1').feature.create('time', 'Transient');
model.study('std1').feature('time').activate('ht', true);

% Keyholeposition festlegen
model.param.set('Lx', KH_x(1)); % [m]
model.param.set('Ly', KH_y(1)); % [m]
model.param.set('phi', sprintf('%.12e [rad]', phiArray(1)));

%ROI Radius festlegen
model.param.set('Cyl_r', sprintf('%.12e [m]', config.las.WaistSize * 3));

%% Geometrie erzeugen
model.geom('geom1').feature('fin').set('repairtol', '1.0E-5');
model.geom('geom1').autoRebuild('off');
% Blech
model.geom('geom1').feature.create('blk1', 'Block');
model.geom('geom1').feature('blk1').set('pos', [0, -config.dis.SampleWidth/2, -config.dis.SampleThickness]);
model.geom('geom1').feature('blk1').set('size', [config.dis.SampleLength, config.dis.SampleWidth, config.dis.SampleThickness]);
model.geom('geom1').feature('blk1').set('createselection', 'on');

% Fein gemeshter Konus
cone = model.geom('geom1').feature.create('roicone', 'ECone');
cone.set('axis', [0, 0, -1]);
cone.set('semiaxes', {'Cyl_r', 'Cyl_r'});
cone.set('pos', {'Lx' 'Ly' '0'});
cone.set('h', 'Cyl_h');
cone.set('displ', [0, 0]);
cone.set('rat', 0.8);
cone.set('rot', 0);
cone.set('createselection', 'on');
clear cone;


%% Keyhole berechnen und in die Geometrie einfügen
fprintf('Calculating KH ...\n');
keyholestart = tic;

clear updateKeyhole;
KH_depth = createKeyhole(model, speedArray(1), config);

keyholetime(i) = toc(keyholestart);
fprintf('done. (%0.1f sec)\n', keyholetime(i));

%% Material zuweisen
initMaterial(model, config);

%% Randbedingungen setzen

model.physics('ht').feature('init1').set('T', 1, sprintf('%d[K]', config.mat.AmbientTemperature));

% Keyhole Innenraum wird ausgeschnitten
% model.physics('ht').feature.create('init2', 'init', 3);
% model.physics('ht').feature('init2').selection.named('KH_Domain');
% model.physics('ht').feature('init2').set('T', 1, config.mat.VaporTemperature);
% model.physics('ht').feature('init2').name('KH_Temp');
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
stats = mphmeshstats(model, 'mesh1');
fprintf('The mesh consists of %d elements. (%d edges)\n', stats.numelem(2), stats.numelem(1));

if (config.sim.confirmMesh)
    subplot(2, 1, 1);
    mphmesh(model, 'mesh1');
    drawnow;
    input('Generated Mesh. Enter to continue...');
end

try
    allstart = tic;
    
    %% Ersten Solver konfigurieren	
	model.study('std1').feature('time').set('tlist', dt(1));
	model.study('std1').feature('time').set('rtol', '0.001');
	model.study('std1').feature('time').set('rtolactive', true);

    Solver = initSolverMultigrid(model, dt(1));
    
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
    
    tweet(sprintf('Starting calculation (%2d/%2d timesteps, %3d elements)', iterations, config.dis.TimeSteps, stats.numelem(2)));
    
    %% Modell lösen
    fprintf('Solving model ... ');
    solverstart = tic;
    Solver.runAll;
    solvertime(i) = toc(solverstart);
    fprintf('done. (%0.1f min)\n', solvertime(i)/60);
    
    model.result('pg').set('data', 'dset1');
    
    %% Volumenintegration erstellen für die interne Energie
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
            ProjectedPool = ProjectedPool | squeeze(any(Pool, 1));
        end
        pooltime(i) = toc(poolstart);
        fprintf('done. (%0.1f min)\n', pooltime(i)/60);
    end
    
    %% MPH speichern
    if (config.sim.saveTimeStepMph)
        fprintf('Saving mph file ... ');
        flushDiary(logPath);
        mphsave(model, sprintf(timeStepMphPath, i));
        fprintf('done.\n');
        flushDiary(logPath);
    end
    
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
    
    if (config.sim.savePictures)
        saveas(gcf, sprintf([output_path 'Figure_%02d.png'], i) ,'png');
    end
    
    SensorTempHist = zeros(iterations,5);
    
    %% Wichtig, da sonst die Nummern der Solver nicht mehr stimmen!
    clear getnextSolver;
    clear getnextSolverMultigrid;
    
    %% Flush diary
    flushDiary(logPath);
    
    %% Convergence counter
    % If this reaches a definied threshold, the calculation is finished. It is
    % reset when the projected pool changes and incremented when it doesn't.
    PoolConvergence = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%    Alle weiteren Iterationen    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Über die Schritte iterieren
    for i=2 : iterations   
        run('runIteration');
    end
    
    %% Schleife beendet, Zeit ausgeben
    clearvars Solver
    
    alltime = toc(allstart);
    progress_msg = sprintf('\nOverall time taken: %dh%02.0fm\n', floor(alltime / 3600), rem(alltime, 3600)/60);
    fprintf(progress_msg);
    tweet(progress_msg);
    
    %% Eingebrachte Leistung in jeder Iteration berechnen
    addedEnergy = diff(energy);
    iterpower = addedEnergy ./ dt(2:iterations)';
    
    %% Daten speichern
    fprintf('Saving iteration times ... ');
    flushDiary(logPath);
    save(timesPath, 'keyholetime', 'meshtime', 'solvertime', 'pooltime', 'energy', 'iterpower');
    fprintf('done.\n');
    flushDiary(logPath);
    
    if (config.sim.saveMph)
        fprintf('Saving mph file ... ');
        flushDiary(logPath);
        mphsave(model, [output_path 'Final_Model.mph']);
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
        fprintf('Saving final temps ...        ');
        flushDiary(logPath);
        
        resolution = 10e-6; % [m]
        range_x = 1e-3 : resolution : 4e-3;
        range_y = -1e-3 : resolution : 1e-3;
        range_z = 0: -resolution : -2e-4;
        
        [YY, XX, ZZ] = meshgrid(range_y, range_x, range_z);
        finalCoords = [XX(:)'; YY(:)'; ZZ(:)'];
        
        ftPageSize = [size(range_x, 2), size(range_y, 2)];
        ftPages = size(range_z, 2);
        finalCoords = reshape(finalCoords, 3, prod(ftPageSize), ftPages);
        FinalTemps = NaN(size(XX));
        
        for z = 1 : ftPages
            Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', finalCoords(:, :, z), 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
            FinalTemps(:, :, z) = reshape(Temps, ftPageSize);
            fprintf('\b\b\b\b\b\b\b%3d/%3d', z, ftPages);
        end
        
        save([output_path 'FinalTemps.mat'], 'range_x', 'range_y', 'range_z', 'FinalTemps', 'finalCoords');
        fprintf('done.\n');
        flushDiary(logPath);
        clear finalCoords resolution range_x range_y range_z XX YY ZZ
    end
    
    % Damit man den Workspace speichern kann, müssen die COMSOL-Objekte
    % gelöscht werden.
    clear ans Solver model;
    save(workspacePath);
    
    progress_msg = sprintf('\nWorkspace saved, calculation finished.\n');
    fprintf(progress_msg);
    tweet(progress_msg);
    
catch msg
    tweet(['Error! Calculation canceled. '  msg.identifier]);
    
    fprintf('Saving iteration times ... ');
    flushDiary(logPath);
    save(timesPath, 'keyholetime', 'meshtime', 'solvertime', 'pooltime', 'energy', 'iterpower');
    fprintf('done.\n');
    flushDiary(logPath);
    
    %% Pool speichern
    if (config.sim.savePool)
        fprintf('Saving pool ... ');
        flushDiary(logPath);
        poolCoords = reshape(poolCoords, 3, prod(poolPageSize) * poolPages);
        save(poolPath, 'Pool', 'poolCoords', 'poolPages', 'poolPageSize');
        fprintf('done.\n');
        flushDiary(logPath);
    end
    
	rethrow (msg);
end

diary off
%% Auf der Workstation die COMSOL-Lizenz freigeben
if (strcmp(getenv('COMPUTERNAME'), 'WAP09CELSIUS4') && config.sim.closeComsol)
    exit
end

if (strcmp(getenv('COMPUTERNAME'), 'POONS') && config.sim.closeComsol)
    exit
end
