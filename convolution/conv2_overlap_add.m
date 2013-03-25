x = lena;
x = x(1:321, 1:400);

[N, M ] = size(x);
sigma = 10;
slant = 0.5;
xi = 3*pi/4;
theta = 0;
offset = [0, 0];

filter_spatial = morlet_2d_noDC(N, M, sigma, slant, xi, theta, offset);