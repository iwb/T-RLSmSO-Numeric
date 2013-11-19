function createMesh( model )
%DEFINEMESH Summary of this function goes here
%   Detailed explanation goes here

%% Fine mesh near the Keyhole
model.mesh('mesh1').feature.create('ftet1', 'FreeTet');
model.mesh('mesh1').feature('ftet1').feature.create('size1', 'Size');

model.mesh('mesh1').feature('ftet1').selection.named('FM_Domain');

model.mesh('mesh1').feature('ftet1').feature('size1').set('custom', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hmaxactive', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hmax', '120 [µm]');       % 60
model.mesh('mesh1').feature('ftet1').feature('size1').set('hminactive', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hmin', '10 [µm]');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hgradactive', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hgrad', '1.4');         % 1.2
model.mesh('mesh1').feature('ftet1').feature('size1').set('hcurveactive', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hcurve', '1.8');         % 1.2
model.mesh('mesh1').feature('ftet1').feature('size1').set('hnarrowactive', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hnarrow', '0.04');       % 0.1

%% Coarse Mesh outside
model.mesh('mesh1').feature.create('ftet2', 'FreeTet');
model.mesh('mesh1').feature('size').set('custom', 'on');
model.mesh('mesh1').feature('size').set('hmax', '1.1 [mm]');
model.mesh('mesh1').feature('size').set('hmin', '120 [µm]');                         % 60
model.mesh('mesh1').feature('size').set('hgrad', '1.2'); % Maximale Wachstumsrate
model.mesh('mesh1').feature('size').set('hcurve', '0.4'); % Kurvenradius, kleiner = feiner
model.mesh('mesh1').feature('size').set('hnarrow', '0.7'); % Auflösung schmaler Regionen. größer = feiner

model.mesh('mesh1').run;
end

