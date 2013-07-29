% function gau = gaussian_2d_spatial(P, sigma, precision)
% TODO : REDO DOC
%
% input :
%	P      : <1x1 int> size of the filter is [2*P+1, 2*P+1] 
%	sigma : <1x1 double> the width of the envelope
%	precision : <string> 'single' or 'double'
%
% output :
% - gab : <NxM double> the morlet filter in spatial domain

function gau = gaussian_2d_spatial(P, sigma, precision)
	
	[x , y] = meshgrid(1:2*P+1, 1:2*P+1);

	x = x - P-1;
	y = y - P-1;
	
	gau = 1/(2*pi*sigma^2) * exp( -(x.^2+y.^2)./(2*sigma^2) );
	
	if (strcmp(precision, 'single'))
		gau = single(gau);
	end
end
