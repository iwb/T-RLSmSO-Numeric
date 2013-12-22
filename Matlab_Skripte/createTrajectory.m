function [ KH_x, KH_y, phiArray, speedArray, dt, Cyl_x ] = createTrajectory( config )
%CREATETRAJECTORY Summary of this function goes here
%   Detailed explanation goes here

	tArray = linspace(0, config.sim.Oscillations / config.osz.Frequency, config.sim.TimeSteps); % = O/f * [t]
	pArray =  linspace(0, 2*pi*config.sim.Oscillations, config.sim.TimeSteps); % = 2*pi*O * [t]

	KH_x = config.dis.StartX + config.osz.Amplitude + ...
		config.osz.FeedVelocity * tArray - config.osz.Amplitude * cos(pArray); % [m]
	KH_y = config.osz.Amplitude * sin(pArray); % [m]
	%plot(KH_x, KH_y, 'o-');

	factor = 2*pi * config.osz.Frequency * config.osz.Amplitude;
	vx = config.osz.FeedVelocity + factor .* sin(pArray);
	vy = factor .* cos(pArray);

	phiArray = atan2(vy, vx);
	speedArray = sqrt(vx.^2 + vy.^2);

	dt = ones(1, config.sim.TimeSteps) .* ...
		config.sim.Oscillations / (config.osz.Frequency * config.sim.TimeSteps);

	% Koordinaten für den Mittelpunkt der Oszillation
	Cyl_x = config.dis.StartX + config.osz.Amplitude + ...
		config.osz.FeedVelocity * tArray;
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