% create a 1d morlet filter bank
N = 16;
L = 4;
filters = tiny_wavelets(N, L);

% display it
display_tiny_wavelets(filters);