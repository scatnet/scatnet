
x = lena;
options.antialiasing = 0;
wavelet = wavelet_factory_3d(size(x), options);
profile on;

[S, U] = scat(x, wavelet);
profile off;
profile viewer;