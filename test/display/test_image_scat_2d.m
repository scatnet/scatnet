x = uiuc_sample;

wavelet = wavelet_factory_2d(size(x));
%%
[S, U] = scat(x, wavelet);
%%
image_scat(S);
%%
image_scat(U);

