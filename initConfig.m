function [ config ] = initConfig()
%INITCONFIG Initialisiert die Einstellungen auf Standardwerte

	config = struct();

	%% Laser Parameter
	config.las.WaveLength = 1064e-9;	% [m]
	config.las.WaistSize = 50e-6;		% [m]

	config.osz.Amplitude = 0.2e-3;		% [m]
	config.osz.Frequency = 200;			% [Hz]
	config.osz.FeedVelocity = 30e-3;	% [m/s]
	config.osz.Power = 1000;    		% [W]
	config.osz.Focus = 0;				% [m] above Surface

	config.dis.SampleWidth = 6e-3;		% [m]
	config.dis.SampleThickness = 3e-3;	% [m]
	config.dis.SampleLength = 12e-3;	% [m]
	config.dis.KeyholeResolution = 40;	% [µm]
	config.dis.StartX = 2e-3;			% [m]
	config.dis.MinimumElemSize = 28e-6;	% [m]
	% A lower value gives a finer mesh along curved boundaries.
	config.dis.Curvature = 0.9;			% [-]
	config.dis.GrowthRate = 1.45;		% [-]

    % Use T-dependent material (will ignore some constants below)
	config.mat.UseSysweld = false; 
	config.mat.ThermalConductivity  = 33.63;   % Wärmeleitfähigkeit [W/(mK)]
	config.mat.Density = 7033;                 % Dichte [kg/m³]
	config.mat.HeatCapacity = 711.4;           % spezifische Wärmekapazität [J/(kgK)]
	config.mat.FresnelEpsilon = 0.25;          % Materialparameter für Fresnel Absorption [-]
	config.mat.FusionEnthalpy = 2.75e5;        % Schmelzenthalpie [J/kg]
	config.mat.MeltingTemperature = 1796;      % Schmelztemperatur [K]
	config.mat.VaporTemperature = 3133;        % Verdampfungstemperatur [K]
	config.mat.AmbientTemperature = 300;       % Umgebungstemperatur [K]

	config.sim.TimeSteps = 30;			% [-]
	config.sim.Oscillations = 1.5;		% [-] X.5 recommended

	config.sim.saveSections = false;
	config.sim.savePool = false;
	config.sim.saveFinalTemps = false;
	config.sim.saveMph = true;
	config.sim.saveVideo = false;
	config.sim.showPlot = false;
	config.sim.showComsolProgress = true;
end

