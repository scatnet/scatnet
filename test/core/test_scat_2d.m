clear; close all;
x = uiuc_sample;
x = x(1:256, 1:256);
%%

filt_opt.J = 4;
scat_opt.oversampling = 0;
[Wop, filters] = wavelet_factory_2d(size(x), filt_opt, scat_opt);

%%
profile on;
tic;
[Sx, Ux] = scat(x, Wop);
toc;
profile off;
profile viewer;