function updateMesh( model )
%UPDATEMESH Summary of this function goes here
	model.mesh('mesh1').feature('ftet1').selection.named('KH_Domain');
	model.mesh('mesh1').feature('ftet1').selection().geom(3).add(2);

	model.mesh('mesh1').run;
end

