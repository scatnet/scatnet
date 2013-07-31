
x = uiuc_sample;
%%
Wop = wavelet_factory_3d_spatial();
tic;
[Sx, Ux] = scat(x, Wop);
toc;
%%
options.oversampling = 0;
Wop2 = wavelet_factory_3d(size(x), options, options, options);

tic;
[Sx2, Ux2] = scat(x, Wop2);
toc;