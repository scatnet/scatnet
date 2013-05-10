x = lena;

options.margins = [0, 0];
[Wavelet, filters] = wavelet_factory_2d(size(x), options);

%%
tic;
[S, U] = scat(x, Wavelet);
toc;