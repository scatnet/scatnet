
clear; close all;
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
%% aply 2d wavelet transform
[x_phi, x_psi] = wavelet_2d(x, filters);

%% aply and profile 3d wavelet transform
profile on;
options.psi_mask = ones(1,numel(filters.psi.filter));
options.psi_mask(1:8) = 0;
y = reshape(abs(cell2mat({x_psi{1:8}})),[sz_in, 8]);
[y_Phi, y_Psi, meta_Phi, meta_Psi] = wavelet_3d(y, filters, filters_rot, options);
profile off;
profile viewer;
plot_meta_layer(y_Psi.meta)

%% check number of coefficient
K = filters_rot.meta.J;
J = filters.meta.J;
L = filters.meta.L;

nb_phi_psi = K;
nb_psi_psi = (J-1)*L;
nb_phi_phi = K*(J-1)*L;
nb_total = nb_phi_psi + nb_psi_psi + nb_phi_phi;
assert( numel(y_Psi) == nb_total);

%% display cut of different signals
close all;

subplot(131);
ycut = abs(y_Psi{1});
ycut = squeeze(ycut(32,:,:));
imagesc(ycut);
title('y * phi psi');

subplot(132);
ycut = abs(y_Psi{4});
ycut = squeeze(ycut(32,:,:));
imagesc(ycut);
title('y * psi phi');

subplot(133);
ycut = abs(y_Psi{5});
ycut = squeeze(ycut(32,:,:));
imagesc(ycut);
title('y * psi psi');


%% check energy 
energ_in = sum(abs(y(:).^2))
energ_out = scat_energy(y_Phi, y_Psi)
