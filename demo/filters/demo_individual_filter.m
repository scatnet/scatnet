%% Creating one filter
% In this demo, we will show how to build some filters in spatial domain or
% Fourier domain. Gabor, Morlet and Gaussian filters are pointed out.
%
%% Reviewed functions
% The following function will be demonstrated:
%%
% 
% # gabor_2d
% # gaussian_2d
% # morlet_2d_noDC
% # morlet_2d_pyramid
%
%% Demonstration
%
% Here are shown 4 examples of filters:

N=50;
M=50;
sigma=10;
slant=3;
theta=pi/3;
xi=2;

gab = gabor_2d(N, M, sigma, slant, xi, theta);
morlet = morlet_2d_noDC(N, M, sigma, slant, xi, theta);
morlet2 = morlet_2d_pyramid(N, M, sigma, slant, xi, theta);
gaussian = gaussian_2d(N, M, sigma);
subplot(2,2,1)
imagesc(real(gab));
axis off
title('Real part of Gabor wavelet in Fourier domain')
subplot(2,2,2)
imagesc(real(morlet));
axis off
title('Real part of Morlet wavelet in Fourier domain')
subplot(2,2,3)
imagesc(real(morlet2));
axis off
title('Real part of Morlet wavelet in Spatial domain')
subplot(2,2,4)
imagesc(gaussian);
axis off
title('Gaussian wavelet')



