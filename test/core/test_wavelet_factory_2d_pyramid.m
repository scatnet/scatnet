clear; close all;
x = uiuc_sample;
filt_opt.size_filter = [7, 7];
filt_opt.L = 6;
wav_opt.J = 4;
options.precision = 'single';
[Wop, filters] = wavelet_factory_2d_pyramid(filt_opt, wav_opt);
tic;
[Sx, Ux] = scat(x, Wop);
toc;


%%

filt_opt.null = 1;
filt_opt.L = 6;
filt_opt.J = 5;
scat_opt.oversampling = 0;
[Wop2, filters2] = wavelet_factory_2d(size(x), filt_opt, scat_opt);
tic;
[Sx2, Ux2]= scat(x, Wop2);
toc;
