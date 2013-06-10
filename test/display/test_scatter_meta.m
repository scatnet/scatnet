x = uiuc_sample;
x = x(1:256, 1:256);
filt_opt.J = 6;
Wop = wavelet_factory_2d(size(x), filt_opt);
%%
Sx = scat(x, Wop);
%%
scatter_meta(Sx{3}.meta, 'j', 1, 'j', 2);