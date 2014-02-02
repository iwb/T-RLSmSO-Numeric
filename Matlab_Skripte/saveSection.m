function saveSection( model, i, coords, filename, sectionPageSize, sectionPages)
%SAVESECTION Summary of this function goes here
%   Detailed explanation goes here

    Temps = zeros([1, prod(sectionPageSize), sectionPages]);

    for ii = 1 : sectionPages
        Temps(:,:,ii) = mphinterp(model, {'T'}, 'dataset', ['dset' num2str(i)], 'coord', coords(:, :, ii), 'Solnum', 'end', 'Matherr', 'on', 'Coorderr', 'on');
    end
    Temps = reshape(Temps, [1, prod(sectionPageSize) * sectionPages]);
    
    save(sprintf(filename, i), 'Temps');
	clear Temps;
end

