size_in = [640, 480];

options.J = 5;

tic;
filters = morlet_filter_bank_2d(size_in, options);
toc;
figure(1);
display_filter_bank_2d(filters, 32, 1);
colormap gray;

figure(2);
display_littlewood_paley_2d(filters);