function depth = updateKeyhole(model, geometry, speed, temp, config)
%UPDATEKEYHOLE Summary of this function goes here
%   Detailed explanation goes here

khg = calcKeyhole(config.dis.KeyholeResolution, speed, temp, config);

CenterArray = khg(2, :);
% Calculate the differences of the centers
DisplacementArray = diff(CenterArray);
RadiusArray = khg(3, :);
RatioArray = RadiusArray(2:end) ./ RadiusArray(1:end-1);
HeightArray = - diff(khg(1, :));

persistent maxTag;

if isempty(maxTag)
	maxTag = 0;
end

for i = 1:size(CenterArray, 2)-1
	% This loops over every gap between two circles. Therefore, the top
	% circle is at i and the bottom circle is at i+1.

    	
	% Position of top circle, relative to the laser center
    pos = {sprintf('Lx + cos(phi) * %.12e [m]', CenterArray(i)), ...
		sprintf('Ly + sin(phi) * %.12e [m]', CenterArray(i)), ...
		sprintf('%.12e [m]', khg(1, i))};	
		
    r = RadiusArray(i);
	height = HeightArray(i);
	
	if (height/r > 10) % Bad condition
		i = i - 1; %#ok<FXSET> b/c we break immediately afterwards
		break;
	end
	
	% Maybe there is already a cone there, we just need to update...
	if (i > maxTag)
		cone = geometry.feature.create(['econ_' num2str(i)], 'ECone');
	else
		cone = geometry.feature(['econ_' num2str(i)]);
	end
	
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

% Remove unused cones
for j = i+1 : maxTag
	model.geom('geom1').feature.remove(['econ_' num2str(j)]);
end

depth = khg(1, i+1);

fprintf('Keyhole was build out of %d elements, %4.0fµm deep.\n', i, -depth * 1e6);

geometry.run; % Damit die Selektion funktioniert...


if (maxTag == 0)
    model.selection.create('KH_Domain', 'Explicit');
end

model.selection('KH_Domain').set(2:i+1);
model.selection('KH_Domain').name('Keyhole_Domain');

if (maxTag == 0)
    model.selection.create('KH_Bounds', 'Adjacent');
    model.selection('KH_Bounds').set('input', 'KH_Domain');
    model.selection('KH_Bounds').name('Keyhole_Bounds');
end

maxTag = i;
end

