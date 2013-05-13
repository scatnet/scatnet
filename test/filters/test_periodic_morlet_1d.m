clear;
N = 1024;

sigma = 5;
xi = 3*pi/4 / sigma;
psi = periodic_morlet_1d(N, sigma, xi);

phi =  periodic_gaussian_1d(N, sigma);