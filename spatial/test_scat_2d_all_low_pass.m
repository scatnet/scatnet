options.all_low_pass = 1;
options.J = 4;

x = uiuc_sample;


Wop = wavelet_factory_2d_pyramid(options, options);
Sx = scat(x, Wop);
