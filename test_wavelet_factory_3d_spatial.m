
x = uiuc_sample;
%%
options.J = 4;
options.precision = 'single';
[Wop,f1,f2] = wavelet_factory_3d_spatial(options, options, options);
tic;
[Sx, Ux] = scat(x, Wop);
toc;
%%
options.oversampling = 0;
options.J = 5;
Wop2 = wavelet_factory_3d(size(x), options, options, options);

tic;
[Sx2, Ux2] = scat(x, Wop2);
toc;