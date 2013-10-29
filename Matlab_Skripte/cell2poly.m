function [ polys ] = cell2poly( cells )
%CELL2POLY Summary of this function goes here
%   Detailed explanation goes here
for ii = 1:size(cells, 2)
	
	cel = cells{ii};
	l = size(cel, 2);
	
	pol = cel{2};
	
	for i=3:2:l
		pol = [pol ' + ' cel{i+1} '*T^' cel{i}];
	end
	polys{ii} =  pol;
end
end

