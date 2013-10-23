thispath = pwd;
cd('../../Keyhole/');
%% Keyhole berechnen
[KH_geom_metric, Reason] = calcKeyhole(40);
%% Keyhole speichern
cd(thispath);
disp(Reason.Name);
save('KH_geom_metric.mat', 'KH_geom_metric');