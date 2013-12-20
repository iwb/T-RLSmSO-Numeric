function initMaterial_comsol( model )

	mat = model.material.create('mat1');
	mat.name('Edelstahl (1.4301)');
	mat.set('family', 'steel');
	
	model.material('mat1').propertyGroup('def').set('thermalconductivity', 'k(T[1/K])[W/(m*K)]');
	mat.propertyGroup('def').set('density', 'rho(T[1/K])[kg/m^3]');
	mat.propertyGroup('def').set('heatcapacity', 'C(T[1/K])[J/(kg*K)]');	
	
	model.material('mat1').propertyGroup('def').func.create('k', 'Piecewise');
	model.material('mat1').propertyGroup('def').func('k').set('funcname', 'k');
	model.material('mat1').propertyGroup('def').func('k').set('arg', 'T');
	model.material('mat1').propertyGroup('def').func('k').set('extrap', 'constant');
	model.material('mat1').propertyGroup('def').func('k').set('pieces', {'45.0' '293.0' '-1.031521+0.1813807*T^1-0.001088656*T^2+3.411681E-6*T^3-3.988389E-9*T^4'; '293.0' '1200.0' '6.742253+0.02864915*T^1'});
	
	
	model.material('mat1').propertyGroup('def').func.create('rho', 'Piecewise');
	model.material('mat1').propertyGroup('def').func('rho').set('funcname', 'rho');
	model.material('mat1').propertyGroup('def').func('rho').set('arg', 'T');
	model.material('mat1').propertyGroup('def').func('rho').set('extrap', 'constant');
	model.material('mat1').propertyGroup('def').func('rho').set('pieces', {'93.0' '1700.0' '7945.333-0.1981948*T^1-3.713764E-4*T^2+2.213069E-7*T^3-5.128456E-11*T^4'});
	
	
	model.material('mat1').propertyGroup('def').func.create('C', 'Piecewise');
	model.material('mat1').propertyGroup('def').func('C').set('funcname', 'C');
	model.material('mat1').propertyGroup('def').func('C').set('arg', 'T');
	model.material('mat1').propertyGroup('def').func('C').set('extrap', 'constant');
	model.material('mat1').propertyGroup('def').func('C').set('pieces', {'128.0' '310.0' '270.215-1.210511*T^1+0.02151566*T^2-7.511841E-5*T^3+8.136796E-8*T^4'; '310.0' '1311.0' '109.2073+2.571775*T^1-0.006528099*T^2+7.787524E-6*T^3-4.167913E-9*T^4+8.090613E-13*T^5'});
end