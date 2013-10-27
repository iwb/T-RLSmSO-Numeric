%%% Wertet die Schnittfelder aus und pplottet mehrere Linien
%clear all;
clc;

figure;
hold all;

x_center = KH_x(end);

for i=1:steps
   filename = sprintf('../Ergebnisse/Section_%02d.mat', i);  
   load(filename);
   
   Feld = reshape(Temps, 401, 1, 151);
   Tline = Feld(:, 1, 1);
   xval = range_x - KH_x(i) + 2;
   
   plot(xval, Tline);
   xlim([0 3])
end