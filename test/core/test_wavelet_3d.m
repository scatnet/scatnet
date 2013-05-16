
clear;
x = lena;
sz_in = size(x);
filters = morlet_filter_bank_2d(sz_in);


sz = 16;
options_rot.boundary = 'per';
options_rot.filter_format = 'fourier_multires';
options_rot.J = 3;
options_rot.P = 0;
filters_rot = morlet_filter_bank_1d(sz, options_rot);

plot_littlewood_1d(filters_rot);
%% aplly 2d wavelet transform
[x_phi, x_psi] = wavelet_2d(x, filters);

%%

%%
profile on;
options.psi_mask = ones(1,numel(filters.psi.filter));
options.psi_mask(1:8) = 0;
options.antialiasing = 1;
y = reshape(abs(cell2mat({x_psi{1:8}})),[sz_in, 8]);
[y_Phi, y_Psi] = wavelet_3d(y, filters, filters_rot, options);
profile off;
profile viewer;
plot_meta_layer(y_Psi.meta)

K = filters_rot.J;
J = filters.meta.J;
L = filters.meta.nb_angle;

nb_phi_psi = K;
nb_psi_psi = (J-1)*L;
nb_phi_phi = K*(J-1)*L;
nb_total = nb_phi_psi + nb_psi_psi + nb_phi_phi;
assert( numel(y_Psi.signal) == nb_total);