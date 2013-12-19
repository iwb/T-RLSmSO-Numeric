function initMaterial_comsol( model )

	mat = model.material.create('mat1');
	mat.name('Eisen');
	mat.set('family', 'iron');
	
	model.material('mat1').propertyGroup('def').set('thermalconductivity', 'k(T[1/K])[W/(m*K)]');
	mat.propertyGroup('def').set('density', 'rho(T[1/K])[kg/m^3]');
	mat.propertyGroup('def').set('heatcapacity', 'C(T[1/K])[J/(kg*K)]');
	
	
	model.material('mat1').propertyGroup('def').func.create('k', 'Piecewise');
	model.material('mat1').propertyGroup('def').func('k').set('funcname', 'k');
	model.material('mat1').propertyGroup('def').func('k').set('arg', 'T');
	model.material('mat1').propertyGroup('def').func('k').set('extrap', 'constant');
	%model.material('mat1').propertyGroup('def').func('k').set('pieces', {'45' '293' '-0.2242957 + 0.7605684*T^1 + -0.04007508*T^2 + 0.002181761*T^3 + -1.836024E-5*T^4';'293' '1200' '8.926275 + -2.900987*T^1 + 0.1470793*T^2 + -0.001254897*T^3 + 3.414011E-6*T^4'});
	
	model.material('mat1').propertyGroup('def').func.create('rho', 'Piecewise');
	model.material('mat1').propertyGroup('def').func('rho').set('funcname', 'rho');
	model.material('mat1').propertyGroup('def').func('rho').set('arg', 'T');
	model.material('mat1').propertyGroup('def').func('rho').set('extrap', 'constant');
	%model.material('mat1').propertyGroup('def').func('rho').set('pieces', {'93' '1700' '-0.2242957 + 0.7605684*T^1 + -0.04007508*T^2 + 0.002181761*T^3 + -1.836024E-5*T^4'});
	
	model.material('mat1').propertyGroup('def').func.create('C', 'Piecewise');
	model.material('mat1').propertyGroup('def').func('C').set('funcname', 'C');
	model.material('mat1').propertyGroup('def').func('C').set('arg', 'T');
	model.material('mat1').propertyGroup('def').func('C').set('extrap', 'constant');
	%model.material('mat1').propertyGroup('def').func('C').set('pieces', {'128' '310' '270.215 + -1.210511*T^1 + 0.02151566*T^2 + -7.511841E-5*T^3 + 8.136796E-8*T^4';'310' '1311' '109.2073 + 2.571775*T^1 + -0.006528099*T^2 + 7.787524E-6*T^3 + -4.167913E-9*T^4 + 8.090613E-13*T^5'});
end