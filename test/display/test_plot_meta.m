x = lena;

Wop = wavelet_factory_2d(size(x));
%%
[Sx, Ux] = scat(x, Wop);

%%
plot_meta(Sx);