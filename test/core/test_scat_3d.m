% this script demonstrates how to compute the roto-translation
% scattering transform of an image

x = mandrill;

filt_opt = struct();
filt_opt.J = 5;
filt_rot_opt = struct();
scat_opt.oversampling = 0;

[Wop, filters, filters_rot ] = ...
		wavelet_factory_3d(size(x), filt_opt, filt_rot_opt, scat_opt);

tic;
[Sx, Ux] = scat(x, Wop);
toc
