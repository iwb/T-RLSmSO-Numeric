function initMaterial_sysweld( model )

%% Funktionen definieren





	model.material.create('mat1');
	model.material('mat1').name('Edelstahl 1.4301');
	model.material('mat1').set('family', 'Steel');
	
	model.material('mat1').propertyGroup('def').set('thermalconductivity', {'70'});
	model.material('mat1').propertyGroup('def').set('density', {'7.8'});
	model.material('mat1').propertyGroup('def').set('heatcapacity', {'1.2'});

end

x = 4:0.1:14;
poly = cell2poly({'0','4.8035','1','-1.973989','2','0.4334444','3', ...
  '-0.03143248','4','8.324035E-4'});

plot(x, polyval(poly, x));
hold all

x = 14:0.1:47;
poly = cell2poly({'0','-0.2242957','1','0.7605684','2', ...
  '-0.04007508','3','0.002181761','4','-1.836024E-5'});
plot(x, polyval(poly, x));

x = 47:0.1:128;
poly = cell2poly({'0','8.926275','1', ...
  '-2.900987','2','0.1470793','3','-0.001254897','4','3.414011E-6'});

plot(x, polyval(poly, x));

x = 128:0.1:310;
poly = cell2poly({'0', ...
  '270.215','1','-1.210511','2','0.02151566','3','-7.511841E-5','4', ...
  '8.136796E-8'});
plot(x, polyval(poly, x));