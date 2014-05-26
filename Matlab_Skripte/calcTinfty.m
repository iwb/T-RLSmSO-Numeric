function [ Tinfty ] = calcTinfty(T_numeric, khg, dt, distance, config)
%CALCTINFTY Summary of this function goes here
%   Detailed explanation goes here

    T_norm = calcTemp(dt, distance, config);

    Tinfty = (T_numeric - T_norm * config.mat.VaporTemperature) / (1 - T_norm);
    fprintf('Equivalent Ambient Temp: %.1f\n', Tinfty);
    Tinfty = max(Tinfty, config.mat.AmbientTemperature);
end

function T_analytic = calcTemp(dt, distance, config)
    kappa = config.mat.ThermalConductivity / (config.mat.Density * config.mat.HeatCapacity);
    
    eta = distance ./ (2 * sqrt(kappa * dt));
    T_analytic = 1 - erf(eta); % Wärmeübertragung (Polifke) Kapitel 14.2.1
end

