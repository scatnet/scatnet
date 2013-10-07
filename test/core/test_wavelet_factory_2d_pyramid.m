clear; close all;
x = uiuc_sample;
x = x(:,:);
filt_opt.size_filter = [7, 7];
filt_opt.L = 8;
wav_opt.J = 6;
[Wop, filters] = wavelet_factory_2d_pyramid(filt_opt, wav_opt);
tic;
[Sx, Ux] = scat(x, Wop);
toc;


%%
filt_opt = struct();
filt_opt.L = 8;
filt_opt.J = 6;
scat_opt.oversampling = 0;
[Wop2, filters2] = wavelet_factory_2d(size(x), filt_opt, scat_opt);
tic;
[Sx2, Ux2]= scat(x, Wop2);
toc;
