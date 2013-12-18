function [ config ] = initConfig()
%INITCONFIG Initialisiert die Einstellungen auf Standardwerte

	config = struct();

	%% Laser Parameter
	config.las.WaveLength = 1064e-9;	% [m]
	config.las.WaistSize = 25e-6;		% [m] (= minimum beam radius)

	config.osz.Amplitude = 0;		% [m]
	config.osz.Frequency = 200;			% [Hz]
	config.osz.FeedVelocity = 0.2;	% [m/s]
	config.osz.Power = 2000;    		% [W]
	config.osz.Focus = 0;				% [m] above Surface

	config.dis.SampleWidth = 6e-3;		% [m]
	config.dis.SampleThickness = 2.5e-3;	% [m]
	config.dis.SampleLength = 10e-3;	% [m]
	config.dis.KeyholeResolution = 10;	% [µm]
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

	config.sim.TimeSteps = 200;					% [-]
	config.sim.Oscillations = 8.5;				% [-] X.5 recommended
	
	% Number of timesteps in which the projected pool needs to stay
	% constant so that the simulation is considered finished.
	config.sim.PoolConvergenceThreshold = ...	% [-] Recommended: One oscillation
		ceil(config.sim.TimeSteps / config.sim.Oscillations);	

	config.sim.confirmMesh = true;
	config.sim.saveSections = false;
	config.sim.savePool = false;
	config.sim.saveFinalTemps = true;
	config.sim.saveMph = true;
	config.sim.saveTimeStepMph = true;
	config.sim.saveVideo = false;
	config.sim.showPlot = false;
	config.sim.showComsolProgress = true;
end

