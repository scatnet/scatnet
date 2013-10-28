%%
clear;
close all;
x = mandrill;
%%
filters = morlet_filter_bank_2d(size(x));
U.signal{1} = x;
U.meta.j = zeros(0,1);

opt_wav = struct();
U2 = wavelet_layer_2d(U, filters, opt_wav);
