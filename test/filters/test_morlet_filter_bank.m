size_in = [256 , 256];

clear options;
options.null = 1;

filters = morlet_filter_bank_2d(size_in, options);
figure(1);
display_filter_bank_2d(filters, 32, 1);
colormap gray;

figure(2);
display_littlewood_paley_2d(filters);