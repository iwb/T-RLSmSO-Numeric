function updateMesh( model )
%UPDATEMESH Summary of this function goes here
	model.mesh('mesh1').feature('ftet1').selection.named('FM_Domain');

	model.mesh('mesh1').run;
end

