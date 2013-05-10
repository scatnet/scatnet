x = lena;
options.J = 6;
wavelet = wavelet_factory_2d(size(x), options);
%%
S = scat(x, wavelet);
%%
scatter_meta(S{3}.meta, 'j', 1, 'j', 2);