function geometry = createKeyhole(model, Apex, Radius)

geometry = model.geom.create('geom1', 3);
geometry.lengthUnit('mm');
geometry.feature.create('blk1', 'Block');


for i = 1:size(Apex, 2)-1
    % Schleife läuft nur für jeden Zwischenraum, der obere Schnitt is immer
    % bei i, der untere bei i+1
    
    
    
end

geometry.feature.create('cyl1', 'Cylinder');
geometry.feature.create('cone1', 'Cone');
geometry.feature('blk1').set('pos', {'0' '-10' '0'});
geometry.feature('blk1').set('size', {'60' '20' '3'});
geometry.feature('cyl1').set('r', '0.1');
geometry.feature('cyl1').set('pos', {'3' '0' '2.5'});
geometry.feature('cyl1').set('h', '0.5');
geometry.feature('cone1').set('axis', {'0' '0' '-1'});
geometry.feature('cone1').set('r', '0.1');
geometry.feature('cone1').set('specifytop', 'radius');
geometry.feature('cone1').set('rtop', '0');
geometry.feature('cone1').set('pos', {'3' '0' '2.5'});
geometry.feature('cone1').set('h', '0.4');
geometry.run;

end