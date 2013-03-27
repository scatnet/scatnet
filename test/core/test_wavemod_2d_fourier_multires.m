% this script compute the 2d wavelet modulus transform of lena
% and verify the conservation of energy

% load lena
x = lena;

% compute filter bank
filters = morlet_filter_bank_2d(size(x));

% define downsampling policy
downsampler = @(k)(k-1);

% compute wavelet modulus transform
[S, U] = wavemod_2d_fourier_multires(x, filters, downsampler);

%%
% check conservation of energy
Wenerg = energize(S, U);
Xenerg = sum(abs((x(:)).^2));
assert(1-Wenerg/Xenerg < 0.01);
fprintf('ratio energy of wavelet transform / energy of signal %f \n', Wenerg/Xenerg);

%%
imagesc(display_gscatt_all(U));