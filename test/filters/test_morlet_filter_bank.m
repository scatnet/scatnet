size_in = [256, 256];

options.slant_psi = 0.5;
filters = morlet_filter_bank_2d(size_in, options);

display_filter_bank_2d(filters, 32, 1);
