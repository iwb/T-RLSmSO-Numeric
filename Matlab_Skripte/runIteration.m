iterstart = tic;

fprintf('Current Time: %s\n\n', datestr(now));
fprintf('Starting iteration %2d/%2d, Timestep: %0.2fms\n', i, iterations, dt(i)*1e3);

%% Zweiten Solver erzeugen
Solver = getNextSolverMultigrid(model, Solver, dt(i));
Solver.feature('t1').set('rtol', config.dis.RelativeTolerance);

%% Virtuelle Umgebungstemperatur errechnen
Pe = config.las.WaistSize / kappa * speedArray(i);
kappa = config.mat.ThermalConductivity / (config.mat.Density * config.mat.HeatCapacity);

KH_pos = [KH_x(i-1) ; KH_y(i-1)];       % Position des vorherigen Keyholes (Laserstrahlachse)
KH_posrec = [KH_x(i) ; KH_y(i)];        % Position des aktuellen Keyholes (Laserstrahlachse)
KH_posreclat = [KH_x(i) ; KH_y(i)] + config.dis.shift * [cos(phiArray(i)+0.5*pi); sin(phiArray(i)+0.5*pi)];     % Position versetzt zu aktuellem KH für 2. Vorheizstreifen
KH_posrecdepth = [KH_x(i) ; KH_y(i)] + khg(3, 1) * [cos(phiArray(i)); sin(phiArray(i))]; %Position an geschätztem Apex des aktuellen KH

% Sensorpunkte im Vorlauf des Keyholes, ausgehend von der Laserstrahlachse
% 10 Strahlradien tangential bzw. lateral versetzt
SensorPointend = KH_posrec + 10 * config.las.WaistSize * [cos(phiArray(i)); sin(phiArray(i))];
SensorPointx = linspace(KH_posrec(1) , SensorPointend(1), config.dis.resvhp);
SensorPointy = linspace(KH_posrec(2) , SensorPointend(2), config.dis.resvhp);
SensorPoint = [SensorPointx', SensorPointy'];
SensorPointlatend = KH_posreclat + 10 * config.las.WaistSize * [cos(phiArray(i)); sin(phiArray(i))];
SensorPointlatx = linspace(KH_posreclat(1) , SensorPointlatend(1), config.dis.resvhp);
SensorPointlaty = linspace(KH_posreclat(2) , SensorPointlatend(2), config.dis.resvhp);
SensorPointlat = [SensorPointlatx', SensorPointlaty'];
SensorPointdepth(:, 3) = [0 : -config.dis.KeyholeResolution * 1e-6: -config.dis.SampleThickness];
SensorPointdepth(:, 1) = KH_posrecdepth(1);
SensorPointdepth(:, 2) = KH_posrecdepth(2);
SensorPoint3 = [SensorPoint, zeros(length(SensorPoint), 1)]';
SensorPointlat3 = [SensorPointlat, zeros(length(SensorPointlat), 1)]';
SensorTemp = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i-1)], 'coord', SensorPoint3, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
SensorTemplat = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i-1)], 'coord', SensorPointlat3, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
SensorTempdepth(:, 1) = SensorPointdepth(:, 3);
SensorTempdepth(:, 2) = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i-1)], 'coord', [SensorPointdepth]', 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
 
fprintf('Sensor Temp max: %.1f\n', max(SensorTemp));
fprintf('Sensor Temp min: %.1f\n', min(SensorTemp));
%T_inf = calcTinfty(SensorTemp, khg, dt(i-1), lookAhead, config);

%% Geometrie updaten
model.param.set('Lx', KH_x(i));
model.param.set('Ly', KH_y(i));
model.param.set('phi', sprintf('%.12e [rad]', phiArray(i)));

fprintf('Calculating KH ...\n');
keyholestart = tic;

if (false)
    plotVorlauf
end

SensorTempHist(i, 1:length(SensorTemp), 1) = SensorTemp';
SensorTempHist(i, 1:length(SensorTemplat), 2) = SensorTemplat';
SensorTempHist(i, 1:length(SensorTempdepth), 3) = SensorTempdepth(:, 1);
SensorTempHist(i, 1:length(SensorTempdepth), 4) = SensorTempdepth(:, 2);
save(temperaturePath, 'SensorTempHist');

SensorPointHist.(genvarname(['i' num2str(i)])).vorlauf = SensorPoint;
SensorPointHist.(genvarname(['i' num2str(i)])).versetzt = SensorPointlat;
SensorPointHist.(genvarname(['i' num2str(i)])).apex = KH_posrecdepth;
save(pointPath, 'SensorPointHist');

% mean(SensorTemps)
KH_depth = updateKeyhole(model, speedArray(i), SensorTemp, SensorTemplat, SensorTempdepth, i, config);
save([output_path '1 KeyholeGeometrie.mat'], 'khg');
khgHist.(genvarname(['i' num2str(i)])) = khg;
save([output_path '1 KeyholeHist.mat'], 'khgHist');
keyholetime(i) = toc(keyholestart);
fprintf('done. (%0.1f sec)\n', keyholetime(i));


%% Mesh updaten
[meshtime(i), stats] = updateMesh(model);

%% Mesh plotten
if (config.sim.showPlot)
    subplot(2, 1, 1);
    mphmesh(model, 'mesh1');
    drawnow;
end

%% Modell Lösen
fprintf('Solving model ... ');
flushDiary(logPath);
solverstart = tic;
Solver.runAll;
solvertime(i) = toc(solverstart);
fprintf('done. (%0.1f min)\n', solvertime(i)/60);

%% Volumenintegration aktualisieren

model.result.numerical('int1').set('data', ['dset' num2str(i)]);
model.result.numerical('int1').setIndex('looplevelinput', 'all', 0);
% Workaround
model.result.numerical('int1').selection.named('geom1_blk1_dom');
model.result.numerical('int1').getReal();
% Richtige Auswertung
model.result.numerical('int1').selection.all;
energy(i, :) = model.result.numerical('int1').getReal();
%energy(i) = model.result.numerical('int1').getReal();
%fprintf('Iterpower: %.1f W\n', (energy(i) - energy(i-1)) ./ dt(i));
%fprintf('Iterpower: %.1f W\n', diff(energy)./dt(i));
save(energyPath, 'energy');

%% Temperaturfeld Plotten
if (config.sim.showPlot)
    if exist('h1', 'var')
        subplot(2, 1, 2);
    else
        h1 = subplot(2, 1, 2);
        ax1 = get(h1,'position'); % Save the position as ax
    end
    mphplot(model, 'pg', 'rangenum', 1);
    set(gca,'position',ax1); % Manually setting this holds the position with colorbar
    drawnow;
end

%% Schnitt speichern
if (config.sim.saveSections)
    fprintf('Saving sections ... ');
    sectionstart = tic;
    saveSection(model, i, sectionCoords, sectionPath, sectionPageSize, sectionPages);
    sectiontime(i) = toc(sectionstart);
    fprintf('done. (%0.1f min)\n', sectiontime(i)/60);
end
flushDiary(logPath);

%% Pool kumulieren
if (config.sim.savePool)
    fprintf('Saving pool ...        ');
    poolstart = tic;
    diary off;
    for z = 1 : poolPages
        Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', poolCoords(:, :, z), 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
        Temps = reshape(Temps, poolPageSize);
        Pool(:, :, z) = Pool(:, :, z) | (Temps > config.mat.MeltingTemperature);
        fprintf('\b\b\b\b\b\b\b%3d/%3d', z, poolPages);
    end
    diary(logPath);
    
    projection = squeeze(any(Pool, 1));
    if any(any(projection & ~ProjectedPool)) % If new points are added
        PoolConvergence = 0;	% Reset the counter
    else
        PoolConvergence = PoolConvergence + 1;
    end
    ProjectedPool = ProjectedPool | projection;
    
    save(poolPath, 'Pool', 'poolPages', 'poolPageSize');
    
    pooltime(i) = toc(poolstart);
    fprintf(' done. (%0.1f min)\n', pooltime(i)/60);
end

%% GIF Animation erzeugen
if (config.sim.saveVideo)
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind, cm, gifPath, 'gif', 'WriteMode', 'append');
end

if (config.sim.savePictures)
    saveas(gcf, sprintf(figurePath, i) ,'png');
end

%% MPH speichern
if (config.sim.saveTimeStepMph)
    fprintf('Saving mph file ... ');
    mphsavestart = tic;
    flushDiary(logPath);
    mphsave(model, sprintf(timeStepMphPath, i));
    
    mphsavetime(i) = toc(mphsavestart);
    fprintf('done. (%0.1f min)\n', mphsavetime(i)/60);
    flushDiary(logPath);
end

%% Fortschritt anzeigen
thistime = toc(iterstart);
progress_msg = sprintf('Iteration %2d/%2d was finished in %.1f minutes\n', i, iterations, thistime/60);

if (i < iterations)
    if ~exist('itertime', 'var')
		itertime = thistime;
	end
	itertime = 0.9 * itertime + 0.1 * thistime;
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
