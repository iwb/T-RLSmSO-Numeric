import com.comsol.model.*
import com.comsol.model.util.*

load([output_path 'KH+Info.mat']);
load(poolPath);

if ~exist('poolCoords', 'var')
    [YY, XX, ZZ] = meshgrid(range_y, range_x, range_z);
    poolCoords = [XX(:)'; YY(:)'; ZZ(:)'];
    poolPageSize = [size(range_x, 2), size(range_y, 2)];
    poolPages = size(range_z, 2);
    poolCoords = reshape(poolCoords, 3, prod(poolPageSize), poolPages);
end
% Pool initialisieren
Pool = false([poolPageSize, poolPages]);
ProjectedPool = false(size(range_y, 2), size(range_z, 2));

% Count files
i = 0;
while(true)
    i = i + 1;
    filename = sprintf('../Ergebnisse/Model_%03d.mph', i);
    if ~exist(filename, 'file')
        break;
    end
end
filecount = i-1;

for i=1:filecount
    filename = sprintf('../Ergebnisse/Model_%03d.mph', i);

    poolstart = tic;
    
    fprintf('Loading %03d ... ', i);
    model = mphload(filename);
    fprintf('done. Accumulating Pool ... ');
    
    for z = 1 : poolPages
        Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', poolCoords(:, :, z), 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
        Temps = reshape(Temps, poolPageSize);
        Pool(:, :, z) = Pool(:, :, z) | (Temps > config.mat.MeltingTemperature);
        ProjectedPool = ProjectedPool | squeeze(any(Pool, 1));
    end
    
    model.result.numerical('int1').set('data', ['dset' num2str(i)]);
    % Workaround
    model.result.numerical('int1').selection.set([]);
    model.result.numerical('int1').selection.all;
    energy(i) = model.result.numerical('int1').getReal(); %#ok<SAGROW>
    
    pooltime = toc(poolstart);
    fprintf('done in %0.1f min.\n', pooltime/60);
    visp = sum(Pool, 3) / 20;
    imshow(visp);
    drawnow;
end