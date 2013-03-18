function gab = gabor_2d(N, M, sigma0, slant, xi, theta, offset)
% function gab = gabor_2d(N, M, sigma0, slant, xi, theta, offset)
%
% 2d elliptic gabor filter
%
% WARNING :
% morlet wavelets have a non-negligeable DC component
% which is damageable to scattering
% conseder the use of morlet_2d.m or morlet_2d_noDC.m
%
% NOTE :
% when used with xi = 0, and slant = 1, this implements a gaussian
%
% inputs :
% - N : <1x1 int> first dimension of the filter
% - M : <1x1 int> second dimension of the filter
% - sigma0 : <1x1 double> the width of the envelope
% - slant : <1x1 double> the excentricity of the elliptic envelope
%            (the smaller slant, the larger angular resolution)
% - xi : <1x1 double> the frequency peak
% - theta : <1x1 double> the orientation in radians of the filter
% - offset : [optional] <2x1 double> : the offset location
%
% output :
% - gab : the gabor filter in spatial domain

if ~exist('offset','var')
    offset = [0,0];
end

[x , y] = meshgrid(1:M,1:N);
x = x - ceil(M/2) - 1;
y = y - ceil(N/2) - 1;
x = x - offset(1);
y = y - offset(2);
Rth = rotation_matrix_2d(theta);
A = inv(Rth) * [1/sigma0^2, 0 ; 0 slant^2/sigma0^2] * Rth ;
s = x.* ( A(1,1)*x + A(1,2)*y) + y.*(A(2,1)*x + A(2,2)*y ) ;
%normalize sucht that the maximum of fourier modulus is 1
gabc = exp( - s/2 + 1i*(x*xi*cos(theta) + y*xi*sin(theta)));
gab = 1/(2*pi*sigma0*sigma0/slant)*fftshift(gabc);

end
