function createMesh_fine( model )
%DEFINEMESH Summary of this function goes here
%   Detailed explanation goes here

%% Fine mesh near the Keyhole
model.mesh('mesh1').feature.create('ftet1', 'FreeTet');
model.mesh('mesh1').feature('ftet1').feature.create('size1', 'Size');

model.mesh('mesh1').feature('ftet1').selection.named('FM_Domain');

model.mesh('mesh1').feature('ftet1').feature('size1').set('custom', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hmaxactive', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hmax', '16 [�m]');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hminactive', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hmin', '5 [�m]');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hgradactive', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hgrad', '1.15');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hcurveactive', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hcurve', '0.15');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hnarrowactive', 'on');
model.mesh('mesh1').feature('ftet1').feature('size1').set('hnarrow', '0.3');

%% Extremly coarse mesh inside of the Keyhole
model.mesh('mesh1').feature.create('ftet2', 'FreeTet');
model.mesh('mesh1').feature('ftet2').feature.create('size1', 'Size');
model.mesh('mesh1').feature('ftet2').selection.named('KH_Domain');
model.mesh('mesh1').feature('ftet2').feature('size1').set('hauto', 9);

%% Coarse Mesh outside
model.mesh('mesh1').feature.create('ftet3', 'FreeTet');
model.mesh('mesh1').feature('size').set('custom', 'on');
model.mesh('mesh1').feature('size').set('hmax', '1.1 [mm]');
model.mesh('mesh1').feature('size').set('hmin', '12 [�m]');
model.mesh('mesh1').feature('size').set('hgrad', '1.3'); % Maximale Wachstumsrate
model.mesh('mesh1').feature('size').set('hcurve', '0.4'); % Kurvenradius, kleiner = feiner
model.mesh('mesh1').feature('size').set('hnarrow', '0.7'); % Aufl�sung schmaler Regionen. gr��er = feiner

%%
model.mesh('mesh1').run;
end

