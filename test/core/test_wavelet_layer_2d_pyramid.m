% Initialize signal and meta
x = mandrill;
U{1}.signal{1} = x;
U{1}.meta.j = zeros(0,1);
filters = morlet_filter_bank_2d_pyramid();
options.J = 3;

[A2, W2] = wavelet_layer_2d_pyramid(U{1}, filters, options)
U2 = modulus_layer(W2);
