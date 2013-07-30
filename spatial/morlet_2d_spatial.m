% function gab = morlet_2d_noDC(N, M, sigma, slant, xi, theta, offset)
% TODO : REDO DOC
% 2d elliptic morlet filter (with analytic formulae)
%
% input :
% - N      : <1x1 int> first dimension of the filter
% - M      : <1x1 int> second dimension of the filter
% - sigma0 : <1x1 double> the width of the envelope
% - slant  : <1x1 double> the excentricity of the elliptic envelope
%            (the smaller slant, the larger angular resolution)
% - xi     : <1x1 double> the frequency peak
% - theta  : <1x1 double> the orientation in radians of the filter
% - offset : [optional] <2x1 double> : the offset location
%
% output :
% - gab : <NxM double> the morlet filter in spatial domain

function gab = morlet_2d_spatial(N, M, sigma, slant, xi, theta, precision, offset)
	
	if ~exist('offset', 'var')
		offset = [1 + floor(N/2), 1 + floor(M/2)];
	end
	
	[x , y] = meshgrid(1:N, 1:M);

	x = x - offset(2);
	y = y - offset(1);
	
	Rth = rotation_matrix_2d(theta);
	A = inv(Rth) * [1/sigma^2, 0 ; 0 slant^2/sigma^2] * Rth ;
	s = x.* ( A(1,1)*x + A(1,2)*y) + y.*(A(2,1)*x + A(2,2)*y ) ;
	
	%normalize sucht that the maximum of fourier modulus is 1
	
	gaussian_envelope = exp( - s/2);
	oscilating_part = gaussian_envelope .* exp(1i*(x*xi*cos(theta) + y*xi*sin(theta)));
	K = sum(oscilating_part(:)) ./ sum(gaussian_envelope(:));
	gabc = oscilating_part - K.*gaussian_envelope;
	
	gab=1/(2*pi*sigma^2/slant^2)*(gabc);
	if (strcmp(precision, 'single'))
		gab = single(gab);
	end
end
