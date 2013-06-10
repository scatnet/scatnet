% compute filters
size_in = [128, 128];
filt_opt.L = 6;
filt_opt.Q = 1;
filt_opt.J = 3;
filters = morlet_filter_bank_2d(size_in, filt_opt);

% display
figure(1);
display_filter_bank_2d(filters, 32, 1);
colormap gray;
figure(2);
display_littlewood_paley_2d(filters);