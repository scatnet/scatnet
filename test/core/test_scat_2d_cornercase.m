x = lena;
x = x(1:1,1:64);

filt_opt.J = 4;
filt_opt.L = 8;
scat_opt.oversampling = 0;
[Wop, filters] = wavelet_factory_2d(size(x), filt_opt, scat_opt);
%%
profile on;
tic;
[Sx, Ux] = scat(x, Wop);
toc;
profile off;
profile viewer;