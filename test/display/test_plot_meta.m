x = lena;

wavelet = wavelet_factory_2d(size(x));
%%
[S, U] = scat(x, wavelet);

%%
plot_meta(S);