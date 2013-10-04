
% load an image
x = uiuc_sample;
x = x(1:256, 1:256);

% compute filter bank
options = struct();
filters = morlet_filter_bank_2d(size(x), options);

%%

tic;
[x_phi, x_psi] = wavelet_2d(x, filters, options);
toc;

% compute energy
energy_x = sum(x(:).^2);
energy_Wx = sum(x_phi.signal{1}(:).^2) + sum(cellfun(@(x)(sum(abs(x(:).^2))),x_psi.signal));