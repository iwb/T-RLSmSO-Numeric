function createKeyhole(model, geometry, speed, config)
% Creates the initial Keyhole by calling update with the ambient
% temperature.

    updateKeyhole(model, geometry, speed, config.mat.AmbientTemperature, config);

end
