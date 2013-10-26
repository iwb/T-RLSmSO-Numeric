function saveSection( model, i, coords )
%SAVESECTION Summary of this function goes here
%   Detailed explanation goes here

    Temps = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', coords, 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on'); %#ok
    save(sprintf('../Ergebnisse/Schnitt_%02d.mat', i), 'Temps');
end

