function TField =  zLayers(Radius, Center, Pe, waistSize)
	
    Alpha = Radius ./ waistSize;
    A = (Center + Radius) ./ waistSize;

    LayerArray = 1;
    x_range = (Center + Radius) + (0:1e-6:1e-4);%(-0.5:1e-2:0.5) * 1e-3;
	y_range = 0;%(-0.5:1e-2:0.5) * 1e-3;
	
	x_range = x_range ./ waistSize;
	y_range = y_range ./ waistSize;
	
	[x, y] = meshgrid(x_range, y_range);
	x = reshape(x, [1, numel(x)]);
	y = reshape(y, [1, numel(y)]);
	
	TField = zeros(length(y_range), length(x_range), length(LayerArray));
    k=1;
	for j = LayerArray
		x_temp = x + (Alpha(j) - A(j));
		[phi, rho] = cart2pol(x_temp, y);
		
		out = (rho < Alpha(j));
		out = reshape(out, [length(y_range), length(x_range)]);
		
		temp = calcTField(phi, rho, Alpha(j), Pe);
		temp = reshape(temp, [length(y_range), length(x_range)]);
		
		temp(out) = 1;
		
		TField(:,:,k) = temp;
        k=k+1;
    end
    
    TField = TField .* (3133-293.15) + 293.15;
end