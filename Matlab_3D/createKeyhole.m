function createKeyhole(model, geometry, point, Apex, Radius)

dz = -12e-6; % Kopiert
tag = 1;

for i = 1:size(Apex, 2)-1
    % Schleife läuft nur für jeden Zwischenraum, der obere Schnitt is immer
    % bei i, der untere bei i+1
    
    pos = point + [Apex(i)-Radius(i); 0; (i-1) * dz * 1e3];
    displacement = Apex(i)-Radius(i) - (Apex(i+1)-Radius(i+1));
    r = Radius(i);
    ratio = Radius(i+1) / Radius(i);
    
    cone = geometry.feature.create(['econ_' num2str(tag)], 'ECone');
    cone.set('axis', [0, 0, -1]);
    cone.set('semiaxes', [r, r]);
    cone.set('pos', pos');
    cone.set('h', dz * -1e3);
    cone.set('displ', [displacement, 0]);
    cone.set('rat', ratio);
    
    tag = tag + 1;
end

geometry.run; % Damit die Selektion funktioniert...

model.selection.create('sel1', 'Explicit');
model.selection('sel1').set(2:size(Apex, 2));
model.selection('sel1').name('Keyhole_Domain');

end

