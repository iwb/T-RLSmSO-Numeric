import com.comsol.model.*
import com.comsol.model.util.*

if exist(energyPath, 'file')
	load(energyPath);
	return;
end
%%
load([output_path '1 KH+Info.mat']);

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

energy = zeros(size(dt));

for i=1:filecount
    filename = sprintf('../Ergebnisse/Model_%03d.mph', i);

    iterstart = tic;
    
    fprintf('Loading %d/%d ... ', i, filecount);
    model = mphload(filename);
    fprintf('done. Evaluating Energy ... ');
    
    model.result.numerical('int1').set('data', ['dset' num2str(i)]);
	% Workaround
	model.result.numerical('int1').selection.named('geom1_blk1_dom');
	model.result.numerical('int1').getReal();
	% Richtige Auswertung
	model.result.numerical('int1').selection.all;
	energy(i) = model.result.numerical('int1').getReal();
    
    itertime = toc(iterstart);
    fprintf('done in %0.1f min.\n', itertime/60);

    plot(energy);
    drawnow;
end
save(energyPath, 'energy');