% this script demonstrates how to compute the roto-translation
% scattering transform of an image

x = uiuc_sample;

filt_opt.null = 1;
filt_rot_opt.null = 1;
scat_opt.oversampling = 0;

[wavelet, filters, filters_rot ] = ...
		wavelet_factory_3d(size(x), filt_opt, filt_rot_opt, scat_opt);

tic;
[S, U] = scat(x, wavelet);
toc