function [ pol ] = cell2poly( cel )
%CELL2POLY Summary of this function goes here
%   Detailed explanation goes here
	l = length(cel);
	
	pol = zeros(1, l/2);
	
	for i=1:2:l
		deg = str2double(cel{i});
		pol(deg+1) = str2double(cel{i+1});
	end
	pol =  fliplr(pol);
end

