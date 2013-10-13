function init_material( model )
    model.material.create('mat1');
    model.material('mat1').info.create('DIN');
    model.material('mat1').info.create('Composition');
    model.material('mat1').propertyGroup('def').func.create('dL', 'Piecewise');
    model.material('mat1').propertyGroup('def').func.create('k', 'Piecewise');
    model.material('mat1').propertyGroup('def').func.create('alpha', 'Piecewise');
    model.material('mat1').propertyGroup('def').func.create('C', 'Piecewise');
    model.material('mat1').propertyGroup('def').func.create('rho', 'Piecewise');
    model.material('mat1').propertyGroup('def').func.create('TD', 'Piecewise');
    
    model.material('mat1').name('X10NiCrMoTiB1515 (DIN 1.4970) [solid]');
    model.material('mat1').info('DIN').body('X 10 Ni Cr Mo Ti B 15-15');
    model.material('mat1').info('Composition').body('bal Fe, (14.5-15.5) Cr, (15-16) Ni, (1.05-1.25) Mo, (1.6-2) Mn, (0.35-0.55) Ti, (0.08-0.12) C, (0.25-0.45) Si, 0.03 P max, 0.015 S max (wt%)');
    model.material('mat1').propertyGroup('def').func('dL').set('pieces', {'293.0' '1273.0' '-0.004001145+1.123311E-5*T^1+9.137522E-9*T^2-2.96589E-12*T^3'});
    model.material('mat1').propertyGroup('def').func('dL').set('arg', 'T');
    model.material('mat1').propertyGroup('def').func('k').set('pieces', {'293.0' '1273.0' '9.200508+0.0132224*T^1+6.943989E-6*T^2-7.160077E-9*T^3+1.702977E-12*T^4'});
    model.material('mat1').propertyGroup('def').func('k').set('arg', 'T');
    model.material('mat1').propertyGroup('def').func('alpha').set('pieces', {'293.0' '1273.0' '1.378384E-5+8.008135E-9*T^1-2.829525E-12*T^2'});
    model.material('mat1').propertyGroup('def').func('alpha').set('arg', 'T');
    model.material('mat1').propertyGroup('def').func('C').set('pieces', {'293.0' '1273.0' '330.7133+0.8038326*T^1-0.001260275*T^2+1.03842E-6*T^3-3.146145E-10*T^4'});
    model.material('mat1').propertyGroup('def').func('C').set('arg', 'T');
    model.material('mat1').propertyGroup('def').func('rho').set('pieces', {'293.0' '1273.0' '8067.331-0.2796353*T^1-2.019394E-4*T^2+7.199288E-8*T^3'});
    model.material('mat1').propertyGroup('def').func('rho').set('arg', 'T');
    model.material('mat1').propertyGroup('def').func('TD').set('pieces', {'293.0' '1273.0' '3.354831E-6-1.551308E-9*T^1+9.499459E-12*T^2-8.71403E-15*T^3+2.630357E-18*T^4'});
    model.material('mat1').propertyGroup('def').func('TD').set('arg', 'T');
    model.material('mat1').propertyGroup('def').set('dL', 'dL(T[1/K])-dL(Tempref[1/K])');
    model.material('mat1').propertyGroup('def').set('thermalconductivity', {'k(T[1/K])[W/(m*K)]' '0' '0' '0' 'k(T[1/K])[W/(m*K)]' '0' '0' '0' 'k(T[1/K])[W/(m*K)]'});
    model.material('mat1').propertyGroup('def').set('thermalexpansioncoefficient', {'alpha(T[1/K])[1/K]+(Tempref-293[K])/(T-Tempref)*(alpha(T[1/K])[1/K]-alpha(Tempref[1/K])[1/K])' '0' '0' '0' 'alpha(T[1/K])[1/K]+(Tempref-293[K])/(T-Tempref)*(alpha(T[1/K])[1/K]-alpha(Tempref[1/K])[1/K])' '0' '0' '0' 'alpha(T[1/K])[1/K]+(Tempref-293[K])/(T-Tempref)*(alpha(T[1/K])[1/K]-alpha(Tempref[1/K])[1/K])'});
    model.material('mat1').propertyGroup('def').set('heatcapacity', 'C(T[1/K])[J/(kg*K)]');
    model.material('mat1').propertyGroup('def').set('density', 'rho(T[1/K])[kg/m^3]');
    model.material('mat1').propertyGroup('def').set('TD', 'TD(T[1/K])[m^2/s]');
    model.material('mat1').propertyGroup('def').addInput('temperature');
    model.material('mat1').propertyGroup('def').addInput('strainreferencetemperature');
end

