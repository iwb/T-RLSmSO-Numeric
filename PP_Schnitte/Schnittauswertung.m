%%% Wertet die Schnittfelder aus und pplottet mehrere Linien
%clear all;
clc;

figure;
hold all;

for i=12:4:steps
   filename = sprintf('D:/FEM_Ergebnisse/Schnitt_%02d.mat', i);  
   load(filename);
    
   Feld = reshape(Temps, 101, 101);
   Feld = Feld(:, end:-1:1);
   Tline = Feld(:, 1);
   xval = (1:101) + 100*(4-KH_x(i));
   
   plot(xval, Tline);
   xlim([1 101])
end