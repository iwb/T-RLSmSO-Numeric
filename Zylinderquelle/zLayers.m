function TField =  zLayers(Alpha, A, Pe, waistSize)
	%LayerArray = [1, linspace(floor(length(A)/4), floor(3*length(A)/4), 4), length(A)];
	LayerArray = [1, 9, 18, 26];
    x_range = (-0.5:1e-2:0.5) * 1e-3;
	y_range = (-0.5:1e-2:0.5) * 1e-3;
	
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
end