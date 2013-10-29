function [ KH_x, KH_y, dt ] = createTrajectory( config )
%CREATETRAJECTORY Summary of this function goes here
%   Detailed explanation goes here

	tArray = linspace(0, config.sim.Oscillations / config.osz.Frequency, config.sim.TimeSteps);

	pArray =  linspace(0, 2*pi*config.sim.Oscillations, config.sim.TimeSteps);

	KH_x = config.dis.StartX + config.osz.Amplitude + ...
		config.osz.FeedVelocity * tArray - config.osz.Amplitude * cos(pArray); % [m]
	KH_y = config.osz.Amplitude * sin(pArray); % [m]
	%plot(KH_x, KH_y, 'o-');
	
	dt = ones(1, config.sim.TimeSteps) .* ...
		config.sim.Oscillations / (config.osz.Frequency * config.sim.TimeSteps);
	
	dt(end) = dt(end)/2;
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