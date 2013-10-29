%%% Wertet die Schnittfelder aus und pplottet mehrere Linien
%clear all;
clc;

figure;
hold all;

load('C:\Daten\FEM\Ergebnisse\Section_Coords.mat');

for i=1:3:steps
	filename = sprintf('../Ergebnisse/Section_%02d.mat', i);  
	load(filename);

	num_x = size(range_x, 2);
	num_y = size(range_y, 2);
	num_z = size(range_z, 2);

	Feld = reshape(Temps, num_x, num_y, num_z);
	Tline = Feld(:, 1, 1);
	xval = range_x - KH_x(i) + 2;

	plot(xval, Tline);
	xlim([0 3])
end