function updateMesh( model )
%UPDATEMESH Summary of this function goes here

	% If there is a fine mesh region, reset the selection because the KH
	% may have changed.
	if strcmp(char(model.mesh('mesh1').current), 'ftet2')
		model.mesh('mesh1').feature('ftet1').selection.named('FM_Domain');
	end
	
	model.mesh('mesh1').run;
end

