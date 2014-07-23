function depth = createKeyhole(model, speed, config, temp, templat, tempdepth, iteration)
% Creates the initial Keyhole by calling update with the ambient
% temperature.

    %depth = updateKeyhole(model, speed, config.mat.AmbientTemperature, config);
    depth = updateKeyhole(model, speed, temp, templat, tempdepth, iteration, config);

end
