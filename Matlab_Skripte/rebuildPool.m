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
Pool = false(size(XX));
ProjectedPool = false(size(range_y, 2), size(range_z, 2));

i = 0;
while(true)
    i = i + 1;
    filename = sprintf('../Ergebnisse/Model_%03d.mph', i);
    
    if ~exist('filename', 'file')
        break;
    end
    
    model = mphload(filename);
    
    fprintf('%03d ... ', i);
    
    poolstart = tic;
    for z = 1 : poolPages
        Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', poolCoords(:, :, z), 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
        Temps = reshape(Temps, poolPageSize);
        Pool(:, :, z) = Pool(:, :, z) | (Temps > config.mat.MeltingTemperature);
        ProjectedPool = ProjectedPool | squeeze(any(Pool, 1));
    end
    pooltime = toc(poolstart);
    fprintf('done. (%0.1f min)\n', pooltime/60);
end