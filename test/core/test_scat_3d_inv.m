% this script demonstrates the rotation covariance-invariance properties
% of roto-translation scattering

x = lena;
x = x(1:256, 1:256);

options.null = 1;
options.antialiasing = 2;

[ wavelet, filters, filters_rot ] = ...
	wavelet_factory_3d(size(x), options);
%%
tic;
[S, U] = scat(x, wavelet);
toc;
%%

x_rot = rot90(x,1);
[S_rot, U_rot] = scat(x_rot, wavelet);

%%

[S_format, meta] = format_scat(S);