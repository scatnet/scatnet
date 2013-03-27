x = lena;

filters = morlet_filter_bank_2d(size(x));
downsampler = @(k)(k-1);

[S, U] = wavemod_2d_fourier_multires(x, filters, downsampler);

%%
immac(display_gscatt_all(U));