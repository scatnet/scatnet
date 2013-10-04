%%
clear;
close all;
%%
% load an image
x = uiuc_sample;
x = x(1:251, 1:256);

% compute filter bank
opt_filters = struct();
opt_filters.min_margin = [25, 800];
filters = morlet_filter_bank_2d(size(x), opt_filters);

%%
opt_wavelet = struct();
tic;
[x_phi, x_psi] = wavelet_2d(x, filters, opt_wavelet);
toc;
%%
% compute energy
energy_x = sum(x(:).^2);
energy_Wx = sum(x_phi(:).^2) + sum(cellfun(@(x)(sum(abs(x(:).^2))),x_psi));