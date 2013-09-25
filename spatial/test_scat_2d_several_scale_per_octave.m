options.Q = 2;
options.J = 5;
Wop = wavelet_factory_2d_pyramid(options, options);

x = uiuc_sample;
tic;
[sx, ux] = scat(x, Wop);
toc;
