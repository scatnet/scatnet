x = lena;

options.nb_scale = 7;

filters = morlet_filter_bank_2d(size(x), options);
downsampler = @(k)(max(0,k-3));




[S, U] = wavemod_2d_fourier_multires(x, filters, downsampler);
%%
% check conservation of energy
Senerg = energize(S);
Uenerg = energize(U);
Wenerg = Senerg+Uenerg;
Xenerg = sum(abs((x(:)).^2));
fprintf('ratio energy of wavelet transform / energy of signal %d \n', Wenerg/Xenerg);

%%
immac(display_gscatt_all(U));