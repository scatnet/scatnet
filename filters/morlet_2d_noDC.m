% MORLET_2D_NODC computes the 2-D elliptic Morlet filter given a set of 
% parameters in Fourier domain
%
% Usage
%    gab = MORLET_2D_NODC(N, M, sigma, slant, xi, theta, offset)
%
% Input
%    N (numeric): width of the filter
%    M (numeric): height of the filter
%    sigma (numeric): standard deviation of the envelope
%    slant (numeric): excentricity of the elliptic envelope
%            (the smaller slant, the larger angular resolution)
%    xi (numeric):  the frequency peak
%    theta (numeric): orientation in radians of the filter
%    offset (numeric): 2-D vector reprensting the offset location.
%    Optional
% 
% Output
%    gab(numeric) : N-by-M matrix representing the gabor filter in spatial
%    domain
%
% Description
%    Compute a Morlet wavelet in Fourier domain. 
%
%    Morlet wavelets have a 0 DC component.
%
% See also
%    GABOR_2D, MORLET_2D_PYRAMID


function gab = morlet_2d_noDC(N, M, sigma, slant, xi, theta, offset)
	
	if ~exist('offset','var')
		offset = [0, 0];
	end
	[x , y] = meshgrid(1:M, 1:N);
	
	x = x - ceil(M/2) - 1 - offset(1);
	y = y - ceil(N/2) - 1 - offset(2);
	
	Rth = rotation_matrix_2d(theta);
	A = Rth\ [1/sigma^2, 0 ; 0 slant^2/sigma^2] * Rth ;
	s = x.* ( A(1,1)*x + A(1,2)*y) + y.*(A(2,1)*x + A(2,2)*y ) ;
	
	%normalize sucht that the maximum of fourier modulus is 1
	
	gaussian_envelope = exp( - s/2);
	oscilating_part = gaussian_envelope .* exp(1i*(x*xi*cos(theta) + y*xi*sin(theta)));
	K = sum(oscilating_part(:)) ./ sum(gaussian_envelope(:));
	gabc = oscilating_part - K.*gaussian_envelope;
	
	gab=1/(2*pi*sigma^2/slant^2)*fftshift(gabc);
	
end
