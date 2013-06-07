size_in = [128, 128];

options.L = 4;
options.Q = 1;
options.J = 3;




tic;
filters = morlet_filter_bank_2d(size_in, options);
toc;
figure(1);
display_filter_bank_2d(filters, 32, 1);
colormap gray;

%image(image_complex(display_filter_2d(filters.psi.filter{end},8)))


figure(2);
display_littlewood_paley_2d(filters);