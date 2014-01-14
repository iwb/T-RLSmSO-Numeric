function depth = updateKeyhole(model, speed, temp, config, varargin)
%UPDATEKEYHOLE Summary of this function goes here
%   Detailed explanation goes here

persistent maxTag;

if (nargin == 5)
    maxTag = varargin{1};
    return;
end

if isempty(maxTag)
	maxTag = 0;
else
    model.geom('geom1').feature.remove('dif1');
    
    % Remove cones
    for j = maxTag : -1 : 1
        model.geom('geom1').feature.remove(['econ_' num2str(j)]);
    end
end

khg = calcKeyhole(config.dis.KeyholeResolution, speed, temp, config);
assignin('base', 'khg', khg);
CenterArray = khg(2, :);
% Calculate the differences of the centers
DisplacementArray = diff(CenterArray);
RadiusArray = khg(3, :);
RatioArray = RadiusArray(2:end) ./ RadiusArray(1:end-1);
HeightArray = - diff(khg(1, :));

conetags = cell(0);

for i = 1:size(CenterArray, 2)-1
	% This loops over every gap between two circles. Therefore, the top
	% circle is at i and the bottom circle is at i+1.

    	
	% Position of top circle, relative to the laser center
    pos = {sprintf('Lx + cos(phi) * %.12e [m]', CenterArray(i)), ...
		sprintf('Ly + sin(phi) * %.12e [m]', CenterArray(i)), ...
		sprintf('%.12e [m]', khg(1, i))};	
		
    r = RadiusArray(i);
	height = HeightArray(i);
	
	if (height/r > 12) % Bad condition
		i = i - 1; %#ok<FXSET> b/c we break immediately afterwards
		break;
    end
    new_tag = ['econ_' num2str(i)];
	conetags{end+1} = new_tag; 
    
	cone = model.geom('geom1').feature.create(new_tag, 'ECone');
    
	ratio = RatioArray(i);
	height_str = sprintf('%.12e', height);

	cone.set('axis', [0, 0, -1]);
	cone.set('semiaxes', [r, r]);
	cone.set('pos', pos);
	cone.set('h', height_str);
	cone.set('displ', [-DisplacementArray(i), 0]);
	cone.set('rat', ratio);
	cone.set('rot', '-phi');
end

depth = khg(1, i+1);

fprintf('Keyhole was build out of %d elements, %4.0f�m deep.\n', i, -depth * 1e6);

%% Zylinder anpassen
Cyl_height = min(config.dis.SampleThickness, -depth * 1.5);
model.param.set('Cyl_h', sprintf('%.12e [m]', Cyl_height));

kappa = config.mat.ThermalConductivity / (config.mat.Density * config.mat.HeatCapacity);
heat_penetration_length = kappa/speed; % [m]

prevR = sscanf(char(model.param.get('Cyl_r')), '%f [m]');
maxR1 = RadiusArray(1) - CenterArray(1) + 6*heat_penetration_length;
maxR2 = RadiusArray(i+1) - CenterArray(i+1) + 6*heat_penetration_length;
newR = max([prevR, maxR1, maxR2]);
model.param.set('Cyl_r', sprintf('%.12e [m]', newR));

%% Geometrie finalisieren

model.geom('geom1').run(conetags{end});
model.geom('geom1').feature.create('dif1', 'Difference');
model.geom('geom1').runPre('dif1');
model.geom('geom1').feature('dif1').selection('input').set({'blk1' 'roicone'});
model.geom('geom1').feature('dif1').selection('input2').set(conetags);

model.geom('geom1').run; % Damit die Selektion funktioniert...

if (maxTag == 0)
    model.selection.create('FM_Domain', 'Explicit');
    % Include the ROI cone in the fine mesh
    model.selection('FM_Domain').set(2);
    model.selection('FM_Domain').name('Fine_Meshed_Domain');

    model.selection.create('KH_Bounds', 'Complement');
    model.selection('KH_Bounds').set('entitydim', '2');    
    model.selection('KH_Bounds').set('input', {'geom1_blk1_bnd' 'geom1_roicone_bnd'});    
    model.selection('KH_Bounds').name('Keyhole_Bounds');
end

maxTag = i;
end

