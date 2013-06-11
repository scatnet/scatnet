x = uiuc_sample;
x = x(1:256, 1:256);
%%
clear options;
%options.margins = [0, 0];
filt_opt.J = 5;
scat_opt.oversampling = 0;
[Wop, filters] = wavelet_factory_2d(size(x), filt_opt, scat_opt);

%%
profile on;
tic;
[Sx, Ux] = scat(x, Wop);
toc;
profile off;
profile viewer;