function [ config ] = initConfig()
%INITCONFIG Initialisiert die Einstellungen auf Standardwerte

	config = struct();

	%% Laser Parameter
	config.las.WaveLength = 1070e-9;	% [m]
	config.las.WaistSize = 28e-6;		% [m] (= minimum beam radius)

	config.osz.Amplitude = 0.55e-3;		% [m]
	config.osz.Frequency = 800;         % [Hz]
	config.osz.FeedVelocity = 0.077;	% [m/s]
	config.osz.Power = 3000;    		% [W]
	config.osz.Focus = 0;				% [m] above Surface

	config.dis.SampleWidth = 30e-3;		% [m]
	config.dis.SampleThickness = 5e-3;	% [m]
	config.dis.SampleLength = 50e-3;	% [m]
	config.dis.KeyholeResolution = 12;	% [µm]
	config.dis.RelativeTolerance = 0.05;% [-]
	config.dis.StartX = 10e-3;			% [m]
    
    config.dis.TimeStepsPerOsz = 20;			% [-]
	config.dis.Oscillations = 3.5;				% [-] X.5 recommended
	config.dis.TimeSteps = 1 + config.dis.TimeStepsPerOsz * config.dis.Oscillations;
    
    config.dis.resvhp = 501;                       % [-] Anzahl an Sensorpunkten im Vorlauf des Keyholes
    config.dis.vhpstepst = 2001;                    % [-] Anzahl an time steps zum Lösen der DGLs bei der Berechnung der VHPs
    config.dis.shift = 0.5 * config.las.WaistSize;  % [m] Versatz zu tangentialem Vorlauf zur Berechnung von A_0

    % Use T-dependent material (will ignore some constants below)
	config.mat.UseSysweld = true; 
    config.mat.SimulatePhaseChange = true;
    config.mat.SimulateRadiation = false;
    config.mat.SimulateConvection = false;
	config.mat.ThermalConductivity  = 28.92;   % Wärmeleitfähigkeit [W/(mK)] (orig. 30.5)
	config.mat.Density = 7361.56;              % Dichte [kg/m³] (orig. 7035)
	config.mat.HeatCapacity = 668.78;          % spezifische Wärmekapazität [J/(kgK)] (orig. 492)
	config.mat.FresnelEpsilon = 0.25;          % Materialparameter für Fresnel Absorption [-]
	config.mat.FusionEnthalpy = 2.75e5;        % Schmelzenthalpie [J/kg]
	config.mat.MeltingTemperature = 1793;      % Schmelztemperatur [K]
	config.mat.VaporTemperature = 3133;        % Verdampfungstemperatur [K]
	config.mat.AmbientTemperature = 300;       % Umgebungstemperatur [K]
	
	% Number of timesteps in which the projected pool needs to stay
	% constant so that the simulation is considered finished.
	config.sim.PoolConvergenceThreshold = ...	% [-] Recommended: One oscillation
		config.dis.TimeStepsPerOsz;	

	config.sim.confirmMesh = false;
	config.sim.saveSections = true;
	config.sim.savePool = true;
	config.sim.saveFinalTemps = true;
	config.sim.saveMph = true;
	config.sim.saveTimeStepMph = true;
	config.sim.saveVideo = false;
    config.sim.savePictures = false;
	config.sim.showPlot = false;
	config.sim.showComsolProgress = true;
	config.sim.closeComsol = false;
end

