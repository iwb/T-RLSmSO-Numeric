function depth = createKeyhole(model, speed, config)
% Creates the initial Keyhole by calling update with the ambient
% temperature.

    depth = updateKeyhole(model, speed, config.mat.AmbientTemperature, config);

end
