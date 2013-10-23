function createKeyhole(model, geometry, khg)

% Adjust the circle centers for the angle
CenterArray = khg(2, :);
% Calculate the differences of the centers
DisplacementArray = diff(CenterArray);
RadiusArray = khg(3, :);
RatioArray = RadiusArray(2:end) ./ RadiusArray(1:end-1);
HeightArray = - diff(khg(1, :), 1, 2);
tag = 1;

for i = 1:size(CenterArray, 2)-1
    % Schleife läuft nur für jeden Zwischenraum, der obere Schnitt is immer
    % bei i, der untere bei i+1
    	
	% Position of top circle, relative to the laser center
    pos = {sprintf('Lx + cos(phi) * %.14e [m]', CenterArray(i)), ...
		sprintf('Ly + sin(phi) * %.14e [m]', CenterArray(i)), ...
		sprintf('%.14e [m]', khg(1, i))};	
	
% 	 % Displacement of bottom circle, relative to the top circle
%     displacement = {sprintf('cos(phi) * %.14e [m]', DisplacementArray(i)), ...
% 		sprintf('-sin(phi) * %.14e [m]', DisplacementArray(i))};	
	
    r = RadiusArray(i) * 1e3;	
    ratio = RatioArray(i);
	height = HeightArray(i) * 1e3;
    	
	cone = geometry.feature.create(['econ_' num2str(tag)], 'ECone');
	cone.set('axis', [0, 0, -1]);
	cone.set('semiaxes', [r, r]);
	cone.set('pos', pos);
	cone.set('h', height);
	cone.set('displ', [-DisplacementArray(i) * 1e3, 0]);
	cone.set('rat', ratio);
	cone.set('rot', '-phi');

	tag = tag + 1;	
	
	if (height/r > 10)
		break;
	end
end

fprintf('Keyhole aus %d Elementen zusammengebaut.\n', tag-1);

geometry.run; % Damit die Selektion funktioniert...

model.selection.create('KH_Domain', 'Explicit');
model.selection('KH_Domain').set(2:tag);
model.selection('KH_Domain').name('Keyhole_Domain');

model.selection.create('KH_Bounds', 'Adjacent');
model.selection('KH_Bounds').set('input', 'KH_Domain');
model.selection('KH_Bounds').name('Keyhole_Bounds');

end
