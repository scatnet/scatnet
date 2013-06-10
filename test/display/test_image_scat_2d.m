x = uiuc_sample;

Wop = wavelet_factory_2d(size(x));
%%
[Sx, Ux] = scat(x, Wop);
%%
image_scat(Sx);
%%
image_scat(Ux);

