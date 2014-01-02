function [ KH_geom, Reason ] = calcKeyhole(zResolution, speed, temperature, config)
%calcKeyhole Berechnet die Geometrie des Keyholes.
%	Parameter ist die Diskretisierung in z-Richtung in µm.
%   Rückgabewert ist eine 3xn Matrix. IN der ersten Spalte ist der
%   zugehörige z-Wert, in der zweiten der Scheitelpunkt und in der dritten
%	Spalte der Radius. Der zweite Rückgabewert gibt den Abbruchgrund an.

% param-struct errechnen (Code Übernahme)

param = struct();
param.w0 = config.las.WaistSize;
param.epsilon = config.mat.FresnelEpsilon;
param.v = speed;
param.I0 = config.osz.Power * 2/(pi*config.las.WaistSize^2); % [W/m2]
param.T0 = temperature;
param.Tv = config.mat.VaporTemperature;
param.lambda = config.mat.ThermalConductivity;
param.kappa = config.mat.ThermalConductivity / (config.mat.Density * config.mat.HeatCapacity);

param.scaled = struct();
param.scaled.waveLength = config.las.WaveLength;
param.scaled.fokus = config.osz.Focus / config.las.WaistSize;
param.scaled.Rl = pi * config.las.WaistSize / config.las.WaveLength;
% Skalierter Vorschub
param.scaled.Pe = param.w0/param.kappa * param.v;
% Skalierte Maximalintensität
param.scaled.gamma = param.w0 * param.I0 / (param.lambda * (param.Tv - param.T0));
% Entdim. Schmelzenthlapie
param.scaled.hm = config.mat.FusionEnthalpy / (config.mat.HeatCapacity*(param.Tv - param.T0));

%% VHP berechnen
versatz = 0.5 * config.las.WaistSize;
vhp1 = vhp_dgl(0, param);
vhp2 = vhp_dgl(versatz, param);
%% Startwerte
A0 = vhp1 / param.w0; % VHP an der Blechoberfläche
% Radius der Schmelzfront an der Oberfläche
alpha0 = ((vhp1 - vhp2)^2 + versatz^2) / (2 * (vhp1 - vhp2)) / config.las.WaistSize;

%% Skalierung und Diskretisierung
% Diskretisierung der z-Achse
dz = zResolution * -1e-6;
d_zeta = dz / param.w0;

% Blechdicke
max_z = config.dis.SampleThickness;
max_zindex = ceil(max_z/-dz);

Apex = NaN(max_zindex, 1);
Apex(1) = A0;

Radius = NaN(max_zindex, 1);
Radius(1) = alpha0;

%% Variablen für die Schleife
zeta = 0;
zindex = 0;

currentA = A0;
currentAlpha = alpha0;

refinement = 2;
KH_geom = zeros(3, max_zindex);

%% Schleife über die Tiefe
while (true)
	
    if (-d_zeta / currentAlpha > 8) && (refinement > 0)
        refinement = refinement - 1;
        d_zeta = d_zeta/2;
    end
    
	zindex = zindex + 1;
	prevZeta = zeta;
	zeta = zeta + d_zeta;
	
	%% Nullstellensuche mit MATLAB-Verfahren
	% Variablen für Nullstellensuche
	arguments = struct();
	arguments.prevZeta = prevZeta;
	arguments.zeta = zeta;
	arguments.d_zeta = d_zeta;
	arguments.prevApex = currentA;
	arguments.prevRadius = currentAlpha;
	
	% Berechnung des neuen Scheitelpunktes
	func1 = @(A) khz_func1(A, arguments, param);
	currentA = fzero(func1, currentA);
	
	% Abbruchkriterium
	if(isnan(currentA))
		Reason = struct('Num', 1, 'Name', sprintf('Abbruch weil Apex = Nan. Endgültige Tiefe: %3.0f\n', zeta));
		break;
	end
	if(currentA < -5)
		Reason = struct('Num', 2, 'Name', sprintf('Abbruch, weil Apex < -5. Endgültige Tiefe: %3.0f\n', zeta));
		break;
	end
	
	% Berechnung des Radius
	func2 = @(alpha) khz_func2(alpha, currentA, arguments, param);
	alpha_interval(1) = 0.5*currentA; % Minimalwert
	alpha_interval(2) = 1.05 * currentAlpha; % Maximalwert
	try
		currentAlpha = fzero(func2, alpha_interval);
	catch err
		Reason = struct('Num', 3, 'Name', sprintf('Abbruch mangels Nullstelle beim Radius. Endgültige Tiefe: %3.0f\n', zeta));
		break;
	end
	
	% Abbruchkriterium
	if(isnan(currentAlpha))
		Reason = struct('Num', 4, 'Name', sprintf('Abbruch weil Radius=Nan. Endgültige Tiefe: %3.0f\n', zeta));
		break;
	end
	if (currentAlpha < 1e-12)
		Reason = struct('Num', 5, 'Name', sprintf('Abbruch weil Keyhole geschlossen. Endgültige Tiefe: %3.0f\n', zeta));
		break;
	end
	if (zindex > 10 && currentAlpha > arguments.prevRadius)
		Reason = struct('Num', 6, 'Name', sprintf('Abbruch weil Radius steigt / KH geschlossen. Endgültige Tiefe: %3.0f\n', zeta));
		break;
	end
	if (zindex >= max_zindex)
		Reason = struct('Num', 7, 'Name', sprintf('Abbruch weil Blechtiefe erreicht.\n'));
		break;
	end
	
	% Werte übernehmen und sichern
    KH_geom(1, zindex+1) = zeta;
	Apex(zindex) = currentA;
	Radius(zindex) = currentAlpha;
end
zindex = zindex - 1;

if (A0 - 2*alpha0) > (Apex(1) - 2*Radius(1))
	alpha0 = A0 - [2, -1] * (Apex(1:2)-Radius(1:2)); % entfernt den Haken
end

KH_geom = KH_geom(:, 1:zindex+1);
KH_geom(2:3, 1) = [A0 - alpha0; alpha0];
KH_geom(2, 2:end) = Apex(1:zindex) - Radius(1:zindex);
KH_geom(3, 2:end) = Radius(1:zindex);

KH_geom = KH_geom .* config.las.WaistSize;
end

