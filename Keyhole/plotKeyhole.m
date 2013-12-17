function plotKeyhole( data )
%PLOTKEYHOLE Summary of this function goes here
%   Detailed explanation goes here
        
		z_axis = data(1, :);
        Center = data(2, :);
		Radius = data(3, :);
		
        axis ij
        ce = plot(Center, z_axis, '-.');
		set(ce,'Color',[.6 .6 .6]); % set the colour to grey
        hold all;
		
        fr = plot(Center - Radius, z_axis, 'Color', [0 0.4 0]);		
        ba = plot(Center + Radius, z_axis, 'Color', [0 0 0.8]);
        
        la = line([0 0], [0 z_axis(end)], 'Color', [0.5 0.5 0.5]);
		
		% VHP
		vhpx = Center(1) + Radius(1);
		vhp = scatter(vhpx, -1e-8, 100, [1 0 0], '*');		
        hold off;
		
		ylim([z_axis(end) 0]);
		
		hleg1 = legend([fr, ba, ce, la, vhp], 'Vorderwand', 'Rückwand', 'Mittelline', 'Laserstrahlachse', 'Vorheizpunkt');
		set(hleg1,'Location','SouthEast');
		
        ylabel('Tiefe [m]');
        xlabel('X-Richtung [m]');
        %daspect([1 1 1]);
        drawnow;        
end