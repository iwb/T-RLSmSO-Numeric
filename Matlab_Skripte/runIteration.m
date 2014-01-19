iterstart = tic;

fprintf('Current Time: %s\n\n', datestr(now));
fprintf('Starting iteration %2d/%2d, Timestep: %0.2fms\n', i, iterations, dt(i)*1e3);

%% Zweiten Solver erzeugen
Solver = getNextSolverMultigrid(model, Solver, dt(i));

%% Virtuelle Umgebungstemperatur errechnen
Pe = config.las.WaistSize / kappa * speedArray(i);
kappa = config.mat.ThermalConductivity / (config.mat.Density * config.mat.HeatCapacity);

KH_pos = [KH_x(i) ; KH_y(i)];
lookAhead = khg(3, 1) +  1 * kappa ./ speedArray(i); % [m]
SensorPoint = KH_pos + lookAhead * [cos(phiArray(i)); sin(phiArray(i))];
distance = sqrt(sum((SensorPoint - KH_pos).^2));

SensorTemp = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i-1)], 'coord', [SensorPoint; 0], 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');

T_inf = calcTinfty(SensorTemp, khg, Pe, config, distance);

%% Geometrie updaten
model.param.set('Lx', KH_x(i));
model.param.set('Ly', KH_y(i));
model.param.set('phi', sprintf('%.12e [rad]', phiArray(i)));

fprintf('Calculating KH ...\n');
keyholestart = tic;

if (false)
    plotVorlauf
end
SensorTempHist(i, :) = SensorTemp;
% mean(SensorTemps)
KH_depth = updateKeyhole(model, speedArray(i), T_inf, config);
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
solverstart = tic;
Solver.runAll;
solvertime(i) = toc(solverstart);
fprintf('done. (%0.1f min)\n', solvertime(i)/60);

%% Volumenintegration aktualisieren

model.result.numerical('int1').set('data', ['dset' num2str(i)]);
% Workaround
model.result.numerical('int1').selection.named('geom1_blk1_dom');
model.result.numerical('int1').getReal();
% Richtige Auswertung
model.result.numerical('int1').selection.all;
energy(i) = model.result.numerical('int1').getReal();
fprintf('Iterpower: %.1f W\n', (energy(i) - energy(i-1)) ./ dt(i));
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
    saveSection(model, i, sectionCoords, sectionPath);
end

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
    flushDiary(logPath);
    mphsave(model, sprintf(timeStepMphPath, i));
    fprintf('done.\n');
    flushDiary(logPath);
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