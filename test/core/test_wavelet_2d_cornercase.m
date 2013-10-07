clear; close all;
x = lena;
x = x(1:13,1:64);
% compute filter bank
opt_filters = struct();
opt_filters.J = 7;
opt_filters.min_margin = [25, 800];
filters = morlet_filter_bank_2d(size(x), opt_filters);
%%
opt_wavelet = struct();
tic;
[x_phi, x_psi, meta_phi, meta_psi] = wavelet_2d(x, filters, opt_wavelet);
toc;
