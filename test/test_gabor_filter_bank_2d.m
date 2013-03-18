size_in = [256, 256];

filters = gabor_filter_bank_2d(size_in);

figure(1);
display_filter_spatial_all(filters);
title('all filters in spatial domain');

figure(2);
display_littlewood_paley(filters);
title('littlewood paley sum of filter bank');
