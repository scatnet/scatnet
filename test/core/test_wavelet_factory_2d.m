x = lena;

size_in = size(x);
options.null = 1;
wavelet = wavelet_factory_2d(size_in, options);
%%
tic;
[S, U] = scat(x, wavelet);
toc;