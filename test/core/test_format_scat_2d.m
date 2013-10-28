%% with mandrill
x = mandrill;

wavelet = wavelet_factory_2d(size(x));
Sx = scat(x, wavelet);
sx = format_scat(Sx);

%% with 32,32 
x = rand(32,32);

filt_opt.J = 3;
filt_opt.L = 6;
scat_opt.oversampling = 2;
[wavelet, filters] = wavelet_factory_2d(size(x), filt_opt, scat_opt);

Sx = scat(x, wavelet);
[s , meta] = format_scat(Sx);
