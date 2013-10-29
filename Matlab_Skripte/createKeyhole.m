function createKeyhole(model, geometry, config, speed)

khg = calcKeyhole(config.dis.KeyholeResolution, speed, config.mat.AmbientTemperature, config);

% Adjust the circle centers for the angle
CenterArray = khg(2, :);
% Calculate the differences of the centers
DisplacementArray = diff(CenterArray);
RadiusArray = khg(3, :);
RatioArray = RadiusArray(2:end) ./ RadiusArray(1:end-1);
HeightArray = - diff(khg(1, :));
tag = 1;

for i = 1:size(CenterArray, 2)-1
	% This loops over every gap between two circles. Therefore, the top
	% circle is at i and the bottom circle is at i+1.
    	
	% Position of top circle, relative to the laser center
    pos = {sprintf('Lx + cos(phi) * %.12e [m]', CenterArray(i)), ...
		sprintf('Ly + sin(phi) * %.12e [m]', CenterArray(i)), ...
		sprintf('%.12e [m]', khg(1, i))};	
		
    r = RadiusArray(i) * 1e3;
	height = HeightArray(i) * 1e3;
	
	if (height/r < 10) % Acceptable condition
		
		ratio = RatioArray(i);
		height_str = sprintf('%.12e', height);

		cone = geometry.feature.create(['econ_' num2str(tag)], 'ECone');
		cone.set('axis', [0, 0, -1]);
		cone.set('semiaxes', [r, r]);
		cone.set('pos', pos);
		cone.set('h', height_str);
		cone.set('displ', [-DisplacementArray(i) * 1e3, 0]);
		cone.set('rat', ratio);
		cone.set('rot', '-phi');

		tag = tag + 1;
		
	else % Bad condition	
				
		height = (khg(1, i) - khg(1, end)) * 1e3;
		height_str = sprintf('%.12e', height);
		displ = CenterArray(end) - CenterArray(i);

		cone = geometry.feature.create(['econ_' num2str(tag)], 'ECone');
		cone.set('axis', [0, 0, -1]);
		cone.set('semiaxes', [r, r]);
		cone.set('pos', pos);
		cone.set('h', height_str);
		cone.set('displ', [-displ * 1e3, 0]);
		cone.set('rat', '0');
		cone.set('rot', '-phi');

		tag = tag + 1;
		
		break;
	end
end

fprintf('Keyhole was build out of %d elements.\n', tag-1);

geometry.run; % Damit die Selektion funktioniert...

model.selection.create('KH_Domain', 'Explicit');
model.selection('KH_Domain').set(2:tag);
model.selection('KH_Domain').name('Keyhole_Domain');

model.selection.create('KH_Bounds', 'Adjacent');
model.selection('KH_Bounds').set('input', 'KH_Domain');
model.selection('KH_Bounds').name('Keyhole_Bounds');

end
