function initMaterial( model, config )

	if (config.mat.UseSysweld)
		initMaterial_sysweld(model);
	else		
		mat = model.material.create('mat1');
		mat.name('Stahl');
		mat.set('family', 'steel');
		mat.propertyGroup('def').set('thermalconductivity', config.mat.ThermalConductivity);
		mat.propertyGroup('def').set('density', config.mat.Density);
		mat.propertyGroup('def').set('heatcapacity', config.mat.HeatCapacity);
	end
end

