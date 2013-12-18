if(true)
    %%
    x_r = 1e-4;
    
    apex_pos = KH_x(i-1) + khg(2, 1) + khg(3, 1);
    fit_factor = 1.0;
    clear SensorCoords;
    clear distance;
    SensorCoords(1, :) = linspace(apex_pos, apex_pos + x_r, 100);
    SensorCoords(2, :) = 0;
    SensorCoords(3, :) = 0;
    SensorTemps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i-1)], 'coord', SensorCoords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
    
    iimax = length(SensorTemps);
    for ii = 1:iimax
        stemp = SensorTemps(ii);
        distance(ii) = SensorCoords(1, ii) - apex_pos;
        kappa = config.mat.ThermalConductivity / (config.mat.Density * config.mat.HeatCapacity);
        eta = -fit_factor*speedArray(i-1) / kappa;
        mattemp(ii) = (stemp - config.mat.VaporTemperature * exp(eta*distance(ii))) / ...
            (1 - exp(eta*distance(ii)));
    end
    
    Pe = config.las.WaistSize / kappa * config.osz.FeedVelocity;
    
    predicted = config.mat.AmbientTemperature + (config.mat.VaporTemperature - config.mat.AmbientTemperature) * exp(-distance*fit_factor * speedArray(i-1)/kappa);
    
    %figure;
    plot(distance, SensorTemps); hold all;
    plot(distance, predicted);
    plot(distance, mattemp); hold off;
    refline(0, config.mat.AmbientTemperature);
    ylim([-500 3200]);
    xlim([0 x_r]);
    
    addpath('../PP_Zylinderquelle');
    tf = Zyl_Vorlauf(khg, Pe, config, 0, distance);
    
    hold all;
    plot(distance, tf, '--', 'Color', [0.6 0 1]);
    hold off;
    
    saveas(gcf, sprintf([output_path 'Figure_%02d.png'], i) ,'png');
end

if(false)
    %%
    lookAhead = 6 * kappa / (speedArray(i-1)); % [m]
    
    clear SensorCoords;
    clear distance;
    SensorCoords(1, :) = linspace(apex_pos, apex_pos + lookAhead, 200);
    SensorCoords(2, :) = 0;
    SensorCoords(3, :) = 0;
    SensorTemps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i-1)], 'coord', SensorCoords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
    
    SensorTemps(end)
    
    figure;
    plot(SensorTemps)
end

if(false)
    %%
    clear SensorCoords
    SensorCoords(1, :) = linspace(config.dis.StartX, apex_pos + 2*x_r, 300);
    SensorCoords(2, :) = 0;
    SensorCoords(3, :) = 0;
    SensorTemps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i-1)], 'coord', SensorCoords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
    
    distance = SensorCoords(1, :) - apex_pos;
    figure;
    plot(distance, SensorTemps);
end