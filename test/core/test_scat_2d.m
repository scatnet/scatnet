x = lena;

%%
clear options;
%options.margins = [0, 0];
options.J = 4;
options.precision_4byte = 1;
options.antialiasing = 3;
[Wavelet, filters] = wavelet_factory_2d(size(x), options);

%%
profile on;
tic;
[S, U] = scat(x, Wavelet);
toc;
profile off;
profile viewer;