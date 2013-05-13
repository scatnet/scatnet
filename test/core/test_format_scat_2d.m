x = lena;

wavelet = wavelet_factory_2d(size(x));
S = scat(x, wavelet);
s = format_scat(S);

%% with mnist
x = retrieve_mnist(1,1,1);
x = x{1}{1};


options.J = 3;
options.nb_angle = 6;
options.antialiasing = 2;
[wavelet, filters] = wavelet_factory_2d(size(x), options);


S = scat(x, wavelet);
[s , meta] = format_scat(S);
