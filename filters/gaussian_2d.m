% GAUSSIAN_2D computes a Gaussian function.
%
% Usage
%    gau = GAUSSIAN_2D(N, M, sigma, precision, offset)
% 
% Input
%    N (numeric): width of the filter matrix
%    M (numeric): height of the filter matrix
%	 sigma (numeric): standard deviation of the Gaussian
%	 precision (string): 'single' or 'double'
%	 offset (numeric): 2-by-1 Vvector index of the row and column of the
%    center of the filter
%
% Output
%    gab (numeric): N-by-M Gaussian function
%
% Description
%    Computes a Gaussian centered in offset and of standard deviation
%    sigma.

function gau = gaussian_2d(N, M, sigma, precision, offset)
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
