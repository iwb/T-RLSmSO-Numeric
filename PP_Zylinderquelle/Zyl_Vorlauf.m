function TField =  Zyl_Vorlauf(khg, Pe, config, z_depth, x_offsets)
	
    Center = interp1(khg(1,:), khg(2,:), z_depth);
    Radius = interp1(khg(1,:), khg(3,:), z_depth);

    Alpha = Radius ./ config.las.WaistSize;
    A = (Center + Radius) ./ config.las.WaistSize;

    LayerArray = 1;
    x_range = (Center + Radius) + x_offsets;
    y_range = 0;

    x_range = x_range ./ config.las.WaistSize;
    y_range = y_range ./ config.las.WaistSize;

    [x, y] = meshgrid(x_range, y_range);
    x = reshape(x, [1, numel(x)]);
    y = reshape(y, [1, numel(y)]);

    TField = zeros(length(y_range), length(x_range), length(LayerArray));
    k=1;
    for j = LayerArray
        x_temp = x + (Alpha(j) - A(j));
        [phi, rho] = cart2pol(x_temp, y);

        out = (rho < Alpha(j));
        out = reshape(out, [length(y_range), length(x_range)]);

        temp = calcTField(phi, rho, Alpha(j), Pe);
        temp = reshape(temp, [length(y_range), length(x_range)]);

        temp(out) = 1;

        TField(:,:,k) = temp;
        k=k+1;
    end

    TField = TField .* (config.mat.VaporTemperature - config.mat.AmbientTemperature) + config.mat.AmbientTemperature;
end