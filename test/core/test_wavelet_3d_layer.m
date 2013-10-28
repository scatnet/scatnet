
clear;
x = mandrill;
sz_in = size(x);
filters = morlet_filter_bank_2d(sz_in);


sz = 16;
options_rot.boundary = 'per';
options_rot.filter_format = 'fourier_multires';
options_rot.J = 3;
options_rot.P = 0;
filters_rot = morlet_filter_bank_1d(sz, options_rot);
close all;
subplot(121);
lw=littlewood_paley(filters);
imagesc(fftshift(lw));
subplot(122);
plot_littlewood_1d(filters_rot);

%% aply 2d wavelet
%[x_phi, x_psi] = wavelet_2d(x, filters);
%W{1} = @(x)(wavelet_2d_layer(x, filters));
W = wavelet_factory_2d(size(x));
W={W{1,1:2}};


[S,U ] = scat(x, W);
%%
U2 = U{2};
options = struct();
[U_Phi, U_Psi] = wavelet_layer_3d(U2, filters, filters_rot, options);