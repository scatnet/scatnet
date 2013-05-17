
%x = imreadBW('ens.png');
x = uiuc_sample;
%x  = x(1:end/2, 1:end/2);
options.antialiasing = 1;
options.precision_4byte = 1;
%wavelet = wavelet_factory_3d(size(x), options);
 [ wavelet, filters, filters_rot ] = ...
		wavelet_factory_3d(size(x), options);
profile on;
tic;
[S, U] = scat(x, wavelet);
toc;
profile off;
profile viewer;