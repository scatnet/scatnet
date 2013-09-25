filters = haar_filter_bank_2d_spatial;

% Initialize signal and meta
x = uiuc_sample;
U{1}.signal{1} = x;
U{1}.meta.j = zeros(0,1);
options.J = 5;

[A2, W2] = wavelet_layer_2d_pyramid(U{1}, filters, options)
U2 = modulus_layer(W2);

%%
clear
x = uiuc_sample;
filt_opt.type = 'haar';
scat_opt.J = 5;
scat_opt.M = 3;
Wop = wavelet_factory_2d_spatial(filt_opt, scat_opt);
Sx = scat(x, Wop);
