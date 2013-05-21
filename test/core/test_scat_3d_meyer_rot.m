% this script demonstrates the use of meyer wavelets along rotation
% to achieve a better decorralation of chanels than morlet wavelets

x = lena;

options.null = 1;
options_rot.meyer_rot = 1;
[W_rt, filters, filters_rot] =...
	wavelet_factory_3d(size(x), options, options_rot);

%%
S_rt = scat(x, W_rt);