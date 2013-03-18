function gab = morlet_2d_noDC(N, M, sigma, slant, xi, theta, offset)
% function gab = morlet_2d_noDC(N, M, sigma, slant, xi, theta, offset)
%
% 2d elliptic morlet filter (with analytic formulae)
%
% WARNING :
% the analytic formulae does not guaranty a zero DC of the wavelet
% especially for high frequency wavelet
% consider the use of morlet_2d_noDC.m that enforce zero DC
%
% input :
% - N : <1x1 int> first dimension of the filter
% - M : <1x1 int> second dimension of the filter
% - sigma0 : <1x1 double> the width of the envelope
% - slant : <1x1 double> the excentricity of the elliptic envelope
%            (the smaller slant, the larger angular resolution)
% - xi : <1x1 double> the frequency peak
% - theta : <1x1 double> the orientation in radians of the filter
% - offset : <2x1 double> [optional] : the offset location
%
% output :
% - gab : the gabor filter in spatial domain

if ~exist('offset','var')
    offset = [0, 0];
end
[x , y] = meshgrid(1:M, 1:N);

x = x - ceil(M/2) - 1;
y = y - ceil(N/2) - 1;
x = x - offset(1);
y = y - offset(2);

Rth = rotation_matrix_2d(theta);
A = inv(Rth) * [1/sigma^2, 0 ; 0 slant^2/sigma^2] * Rth ;
s = x.* ( A(1,1)*x + A(1,2)*y) + y.*(A(2,1)*x + A(2,2)*y ) ;

%normalize sucht that the maximum of fourier modulus is 1

gaussian_envelope = exp( - s/2);
oscilating_part = gaussian_envelope .* exp(1i*(x*xi*cos(theta) + y*xi*sin(theta)));
K = sum(oscilating_part(:)) ./ sum(gaussian_envelope(:));
gabc = oscilating_part - K.*gaussian_envelope;

gab=1/(2*pi*sigma^2/slant)*fftshift(gabc);

end
