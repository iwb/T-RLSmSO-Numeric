function [ config ] = initConfig()
%INITCONFIG Summary of this function goes here
%   Detailed explanation goes here

	config = struct();
	
	%% Laser Parameter
	config.las.WaveLength = 1064e-9;	% [m]
	config.las.WaistSize = 50e-6;		% [m]
	
	config.osz.Amplitude = 0.3e-3;		% [m]
	config.osz.Frequency = 300;			% [Hz]
	config.osz.FeedVelocity = 16e-3;	% [m/s]
	config.osz.Power = 1000;			% [W]
	config.osz.Focus = 0;				% [m] above Surface
	
	config.dis.SampleWidth = 4e-3;		% [m]
	config.dis.SampleThickness = 3e-3;	% [m]
	config.dis.SampleLength = 10e-3;	% [m]
	config.dis.StartX = 2e-3;			% [m]
	
	config.dis.MinimumElemSize = 28e-6;	% [m]
	% A lower value gives a finer mesh along curved boundaries. 
	config.dis.Curvature = 0.5;			% [-]
	config.dis.GrowthRate = 1.35;		% [-]
	
	config.mat.UseSysweld = true;		% Use T-dependent material (will ignore constants)
	config.mat.ThermalConductivity  = 33.63;   % W�rmeleitf�higkeit [W/(mK)]
    config.mat.Density = 7033;                 % Dichte [kg/m�]
	config.mat.HeatCapacity = 711.4;           % spezifische W�rmekapazit�t [J/(kgK)]
	config.mat.FresnelEpsilon = 0.25;          % Materialparameter f�r Fresnel Absorption [-]
	config.mat.FusionEnthalpy = 2.75e5;        % Schmelzenthalpie [J/kg]
	config.mat.MeltingTemperature = 1796;      % Schmelztemperatur [K]
	config.mat.VaporTemperature = 3133;        % Verdampfungstemperatur [K]
	config.mat.AmbientTemperature = 300;       % Umgebungstemperatur [K]
	
	config.sim.TimeSteps = 30;			% [-]
	config.sim.Oscillations = 1.5;		% [-] X.5 recommended
	
	config.sim.saveSections = true;
	config.sim.savePool = false;
	config.sim.saveFinalTemps = true;
	config.sim.saveMph = true;
	config.sim.saveVideo = false;
	config.sim.showPlot = false;
	config.sim.showComsolProgress = false;
end
