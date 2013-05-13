x = lena
x = x(1:256, 1:256);
%%
x = imreadBW('ens.png');
%%
clear options;
%options.margins = [0, 0];
options.J = 4;
[Wavelet, filters] = wavelet_factory_2d(size(x), options);

%%
profile on;
tic;
[S, U] = scat(x, Wavelet);
toc;
profile off;
profile viewer;