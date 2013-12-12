function plotKeyhole( data )
%PLOTKEYHOLE Summary of this function goes here
%   Detailed explanation goes here
        
		z_axis = data(1, :);
        Center = data(2, :);
		Radius = data(3, :);
		
        axis ij
        plot(Center + Radius, z_axis);
        hold all;
        p = plot(Center, z_axis, '-.');
		set(p,'Color',[.7 .7 .7]); % set the colour to grey
        plot(Center - Radius, z_axis);
		
        
        line([0 0], [0 z_axis(end)], 'Color', [0.5 0.5 0.5])
        hold off;
        ylabel('Tiefe [m]');
        xlabel('X-Richtung [m]');
        %daspect([1 1 1]);
        drawnow;        
end