% function gau = gaussian_2d_spatial(P, sigma, precision)
% TODO : REDO DOC
%
% input :
%	N : <1x1 int> number of rows for the filter matrix
%	M : <1x1 int> number of columns for the filter matrix
%	sigma : <1x1 double> the width of the envelope
%	precision : <string> 'single' or 'double'
%	offset <2x1 int> index of the row and column of the center of the
%		filter
%
% output :
% - gab : <NxM double> the morlet filter in spatial domain

function gau = gaussian_2d_spatial(N, M, sigma, precision, offset)
	if (~exist('offset', 'var'))
		offset = [1 + floor(N/2), 1 + floor(M/2)];
	end
	
	[x , y] = meshgrid(1:M, 1:N);

	x = x - offset(2);
	y = y - offset(1);
	
	gau = 1/(2*pi*sigma^2) * exp( -(x.^2+y.^2)./(2*sigma^2) );
	
	if (strcmp(precision, 'single'))
		gau = single(gau);
	end
end
