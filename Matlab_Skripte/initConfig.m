function [ config ] = initConfig()
%INITCONFIG Initialisiert die Einstellungen auf Standardwerte

	config = struct();

	%% Laser Parameter
	config.las.WaveLength = 1064e-9;	% [m]
	config.las.WaistSize = 25e-6;		% [m] (= minimum beam radius)

	config.osz.Amplitude = 0.2e-3;		% [m]
	config.osz.Frequency = 1100;			% [Hz]
	config.osz.FeedVelocity = 0.108;	% [m/s]
	config.osz.Power = 2000;    		% [W]
	config.osz.Focus = 0;				% [m] above Surface

	config.dis.SampleWidth = 6e-3;		% [m]
	config.dis.SampleThickness = 2.5e-3;	% [m]
	config.dis.SampleLength = 10e-3;	% [m]
	config.dis.KeyholeResolution = 12;	% [µm]
	config.dis.StartX = 2e-3;			% [m]
    
    config.dis.TimeStepsPerOsz = 20;			% [-]
	config.dis.Oscillations = 9.5;				% [-] X.5 recommended
	config.dis.TimeSteps = 1 + config.dis.TimeStepsPerOsz * config.dis.Oscillations;

    % Use T-dependent material (will ignore some constants below)
	config.mat.UseSysweld = true; 
	config.mat.ThermalConductivity  = 30.5;    % Wärmeleitfähigkeit [W/(mK)]
	config.mat.Density = 7035;                 % Dichte [kg/m³]
	config.mat.HeatCapacity = 492;             % spezifische Wärmekapazität [J/(kgK)]
	config.mat.FresnelEpsilon = 0.25;          % Materialparameter für Fresnel Absorption [-]
	config.mat.FusionEnthalpy = 2.75e5;        % Schmelzenthalpie [J/kg]
	config.mat.MeltingTemperature = 1793;      % Schmelztemperatur [K]
	config.mat.VaporTemperature = 3133;        % Verdampfungstemperatur [K]
	config.mat.AmbientTemperature = 300;       % Umgebungstemperatur [K]
	
	% Number of timesteps in which the projected pool needs to stay
	% constant so that the simulation is considered finished.
	config.sim.PoolConvergenceThreshold = ...	% [-] Recommended: One oscillation
		ceil(config.dis.TimeSteps / config.dis.Oscillations);	

	config.sim.confirmMesh = true;
	config.sim.saveSections = true;
	config.sim.savePool = true;
	config.sim.saveFinalTemps = true;
	config.sim.saveMph = true;
	config.sim.saveTimeStepMph = true;
	config.sim.saveVideo = true;
    config.sim.savePictures = true;
	config.sim.showPlot = true;
	config.sim.showComsolProgress = true;
	config.sim.closeComsol = false;
end

