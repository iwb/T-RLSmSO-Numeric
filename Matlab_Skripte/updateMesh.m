function [meshtime,stats] =  updateMesh( model )
%UPDATEMESH Updates the mesh bc the geometry has changed
	
    fprintf('Remeshing ... ');
	meshstart = tic;
	model.geom('geom1').run;

	% If there is a fine mesh region, reset the selection because the KH
	% may have changed.
	if strcmp(char(model.mesh('mesh1').current), 'ftet2')
		model.mesh('mesh1').feature('ftet1').selection.named('FM_Domain');
    end
    if strcmp(char(model.mesh('mesh1').current), 'ftet3')
		model.mesh('mesh1').feature('ftet2').selection.named('KH_Domain');
	end
	
	model.mesh('mesh1').run;
    try % Der Vollständigkeit halber
       model.mesh('mesh2').run;
       model.mesh('mesh3').run;
       model.mesh('mesh4').run;
    catch
    end
    
    meshtime = toc(meshstart);
	fprintf('done. (%0.1f sec)\n', meshtime);
	
	stats = mphmeshstats(model, 'mesh1');
	fprintf('The mesh consists of %d elements. (%d edges)\n', stats.numelem(2), stats.numelem(1));
end

