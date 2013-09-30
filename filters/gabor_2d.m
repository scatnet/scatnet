% GABOR_2D computes the 2-D elliptic gabor wavelet given a set of 
% parameters
%
% Usage
%    gab = GABOR_2D(N, M, sigma0, slant, xi, theta, offset, precision)
%
% Input
%    N (numeric): width of the filter
%    M (numeric): height of the filter
%    sigma0 (numeric): standard deviation of the envelope
%    slant (numeric): excentricity of the elliptic envelope
%            (the smaller slant, the larger angular resolution)
%    xi (numeric):  the frequency peak
%    theta (numeric): orientation in radians of the filter
%    offset (numeric): 2-D vector reprensting the offset location.
%    Optional
%    precision (string): precision of the computation. Optional
% 
% Output
%    gab(numeric) : N-by-M matrix representing the gabor filter in spatial
%    domain
%
% Description
%    Compute a gabor wavelet. When used with xi = 0, and slant = 1, this 
%    implements a gaussian
%
%    Morlet wavelets have a non-negligeable DC component which is
%    removed for scattering computation. To avoid this problem, one can use
%    MORLET_2D_NODC.
%
% See also
%    MORLET_2D_NODC

function gab = gabor_2d(N, M, sigma0, slant, xi, theta, offset, precision)
	
	if ~exist('offset','var')
		offset = [0,0];
	end
	if ~exist('precision', 'var')
		precision = 'double';
	end
	
	[x , y] = meshgrid(1:M,1:N);
	x = x - ceil(M/2) - 1;
	y = y - ceil(N/2) - 1;
	x = x - offset(1);
	y = y - offset(2);
	Rth = rotation_matrix_2d(theta);
	A = Rth \ [1/sigma0^2, 0 ; 0 slant^2/sigma0^2] * Rth ;
	s = x.* ( A(1,1)*x + A(1,2)*y) + y.*(A(2,1)*x + A(2,2)*y ) ;
	% Normalization
	gabc = exp( - s/2 + 1i*(x*xi*cos(theta) + y*xi*sin(theta)));
	gab = 1/(2*pi*sigma0*sigma0/slant)*fftshift(gabc);
	
	if (strcmp(precision, 'single'))
		gab = single(gab);
	end
	
end
