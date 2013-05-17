
x = imreadBW('ens.png');
x  = x(1:end/2, 1:end/2);
options.antialiasing = 0;
options.precision_4byte = 0;
%wavelet = wavelet_factory_3d(size(x), options);
 [ wavelet, filters, filters_rot ] = ...
		wavelet_factory_3d(size(x), options);
profile on;

[S, U] = scat(x, wavelet);
profile off;
profile viewer;