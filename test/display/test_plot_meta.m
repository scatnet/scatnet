x = uiuc_sample;
x = x(1:256, 1:256);

Wop = wavelet_factory_2d(size(x));
%%
[Sx, Ux] = scat(x, Wop);

%%
plot_meta(Sx);