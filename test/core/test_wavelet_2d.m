
% load lena
x = lena;

profile on
% compute filter bank
clear options;
%options.margins =  [0, 0];
options.null = 1;
filters = morlet_filter_bank_2d(size(x), options);

profile off;
profile viewer;
%%
options.antialiasing = 0;
%profile on;
tic;
[x_phi, x_psi] = wavelet_2d(x, filters, options);
toc;
% profile off;
% profile viewer;
% compute energy
energy_x = sum(x(:).^2);
energy_Wx = sum(x_phi(:).^2) + sum(cellfun(@(x)(sum(abs(x(:).^2))),x_psi));