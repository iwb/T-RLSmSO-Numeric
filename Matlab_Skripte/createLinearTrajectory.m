function [ KH_x, KH_y, phiArray, speedArray, dt, Sensor_x, Sensor_y, Cyl_x ] = createLinearTrajectory( config )
%CREATETRAJECTORY Summary of this function goes here
%   Detailed explanation goes here

	ts = config.sim.TimeSteps;
	dist = 3e-3;
    
    dx_last = 3e-6;
    cc = [ts, -ts^2; 1, -2*ts] \ [dist; dx_last];
    KH_x = config.dis.StartX + cc(1) * (1:ts) - cc(2) * (1:ts).^2; % [mm]
	
	tArray = linspace(0, dist ./ config.osz.FeedVelocity, config.sim.TimeSteps); % = d/v * [t]
	pArray =  linspace(0, dist, config.sim.TimeSteps); % = d * [t]
	
	%KH_x = linspace(config.dis.StartX, config.dis.StartX + dist, ts);
	KH_y = zeros(1, ts);
    
	phiArray = zeros(1, ts);
    speedArray = ones(1, config.sim.TimeSteps) .* config.osz.FeedVelocity;
	
	dt = ones(1, config.sim.TimeSteps) .* ( dist ./ config.osz.FeedVelocity / ts);
		
	% Koordinaten für den Mittelpunkt der Oszillation

	Cyl_x = KH_x;
    
    
    %% Adjust timestamps
	% Sensorpunkte in einen passenden Abstand setzen
    kappa = config.mat.ThermalConductivity / (config.mat.Density * config.mat.HeatCapacity);       
    lookAhead = 6 * kappa ./ (speedArray.^2); % [s]
    
        
	tArray = tArray + lookAhead;
	pArray = pArray + lookAhead .* 2*pi*config.osz.Frequency;

	Sensor_x = config.dis.StartX + config.osz.Amplitude + ...
		config.osz.FeedVelocity * tArray - config.osz.Amplitude * cos(pArray); % [m]
	Sensor_y = config.osz.Amplitude * sin(pArray); % [m]
end

%% Quadratische Zeitschritte

% steps = 40;
% distance = 2.5; % [mm]
% dx_last = 3e-2;
% cc = [steps, -steps^2; 1, -2*steps] \ [distance; dx_last];
% KH_x = 2 + cc(1) * (1:steps) - cc(2) * (1:steps).^2; % [mm]
% 
% dt = diff(KH_x) ./ v;
% dt(end + 1) = dx_last/v;
% 
% KH_y = zeros(size(KH_x));
%	plot(KH_x, KH_y, 'o-');
%	plot(KH_x, 'o-');