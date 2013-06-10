x = lena;

%%
clear options;
%options.margins = [0, 0];
filt_opt.J = 5;
scat_opt.antialiasing = 3;
[Wavelet, filters] = wavelet_factory_2d(size(x), filt_opt, scat_opt);

%%
profile on;
tic;
[S, U] = scat(x, Wavelet);
toc;
profile off;
profile viewer;