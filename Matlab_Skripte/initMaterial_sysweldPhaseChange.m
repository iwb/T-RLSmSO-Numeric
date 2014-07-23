function initMaterial_sysweld( model, ~ )

	mat = model.material.create('mat1');
	mat.name('Edelstahl 1.4301');
	mat.set('family', 'steel');
	
	model.material('mat1').propertyGroup('def').set('thermalconductivity', 'k(T[1/K])[W/(m*K)]');
	mat.propertyGroup('def').set('density', 'rho(T[1/K])[kg/m^3]');
	mat.propertyGroup('def').set('heatcapacity', 'C(T[1/K])[J/(kg*K)]');
	
	
	
	func = model.material('mat1').propertyGroup('def').func.create('k', 'Interpolation');
	func.set('funcname', 'k');
	func.set('extrap', 'const');
	func.set('interp', 'piecewisecubic');
	%func.set('table',  {'273.15' '16'; '673.15' '20.5'; '1633.15' '32.4'; '2773.15'  '32.4'});
    
    model.material('mat1').propertyGroup('def').func('k').set('source', 'file');
    model.material('mat1').propertyGroup('def').func('k').set('filename', 'lambda_table.csv');
    model.material('mat1').propertyGroup('def').func('k').importData;
		
	func = model.material('mat1').propertyGroup('def').func.create('rho', 'Interpolation');
	func.set('funcname', 'rho');
	func.set('extrap', 'const');
	func.set('interp', 'cubicspline');
	%func.set('table',  {'273.15' '7912'; '473.15' '7840'; '673.15' '7752'; '1073.15' '7560'; '1273.15' '7456'; '1473.15' '7352'; '1873.15' '7140'});
	
    model.material('mat1').propertyGroup('def').func('rho').set('source', 'file');
    model.material('mat1').propertyGroup('def').func('rho').set('filename', 'rho_table.csv');
    model.material('mat1').propertyGroup('def').func('rho').importData;
	
	
 	func = model.material('mat1').propertyGroup('def').func.create('C', 'Interpolation');
 	func.set('funcname', 'C');
 	func.set('extrap', 'const');
 	func.set('interp', 'piecewisecubic');	
% 	%func.set('table',  {'273.15' '511'; '473.15' '542'; '673.15' '575'; '873.15' '605'; '1073.2' '630'; '1273.2' '655'; '1473.2' '670'; '1623.2' '685'; '2773.2' '730'});
%   func.set('table',  {'273.15' '511'; '473.15' '542'; '673.15' '575'; '873.15' '605'; '1073.2' '630'; '1273.2' '655'; '1459.2' '673.7'; '1702' '2239'; '1935' '703.5'; '2773.2' '730'});
    
    model.material('mat1').propertyGroup('def').func('C').set('source', 'file');
    model.material('mat1').propertyGroup('def').func('C').set('filename', 'cp2_table.csv');
    model.material('mat1').propertyGroup('def').func('C').importData;

end