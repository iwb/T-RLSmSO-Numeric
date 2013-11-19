function createMesh( model )
%DEFINEMESH Summary of this function goes here
%   Detailed explanation goes here

%% One mesh for everything
model.mesh('mesh1').feature.create('ftet1', 'FreeTet');

model.mesh('mesh1').feature('size').set('custom', 'on');
model.mesh('mesh1').feature('size').set('hmax', '1.1 [mm]');
model.mesh('mesh1').feature('size').set('hmin', '60 [µm]');                         % 60
model.mesh('mesh1').feature('size').set('hgrad', '1.4'); % Maximale Wachstumsrate
model.mesh('mesh1').feature('size').set('hcurve', '0.8'); % Kurvenradius, kleiner = feiner
model.mesh('mesh1').feature('size').set('hnarrow', '0.07'); % Auflösung schmaler Regionen. größer = feiner

model.mesh('mesh1').run;
end

