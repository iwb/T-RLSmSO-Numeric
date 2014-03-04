%% Schleife beendet, Zeit ausgeben
clearvars Solver

if exist('allstart', 'var')
    alltime = toc(allstart);
    progress_msg = sprintf('\nOverall time taken: %dh%02.0fm\n', floor(alltime / 3600), rem(alltime, 3600)/60);
    fprintf(progress_msg);
    tweet(progress_msg);
end

%% Eingebrachte Leistung in jeder Iteration berechnen
addedEnergy = diff(energy);
iterpower = addedEnergy ./ dt(2:iterations)';

%% Daten speichern
fprintf('Saving iteration times ... ');
flushDiary(logPath);
save(energyPath,  'energy', 'addedEnergy', 'iterpower');
save(timesPath, 'itertime', 'keyholetime', 'meshtime', 'pooltime', 'solvertime');
fprintf('done.\n');
flushDiary(logPath);

if (config.sim.saveMph)
    fprintf('Saving mph file ... ');
    flushDiary(logPath);
    mphsave(model, [output_path '8 Final_Model.mph']);
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
    
    diary off;
    for z = 1 : ftPages
        Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', finalCoords(:, :, z), 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
        FinalTemps(:, :, z) = reshape(Temps, ftPageSize);
        fprintf('\b\b\b\b\b\b\b%3d/%3d', z, ftPages);
    end    
    diary(logPath);
    
    save([output_path 'FinalTemps.mat'], 'range_x', 'range_y', 'range_z', 'FinalTemps', 'finalCoords');
    fprintf(' done.\n');
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