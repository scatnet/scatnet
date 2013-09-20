%% spatial
src = uiuc_src;
options.J = 5;
options.Q = 1;
options.M = 2;

options.parallel = 0;
Wop = wavelet_factory_2d_spatial(options, options);
%fun = @(filename)(scat(imreadBW(filename), Wop));
scatfun = @(x)(scat(x, Wop));
multi_fun = @(filename)(fun_multiscale(scatfun, imreadBW(filename), sqrt(2), 4));
all_feat = srcfun(multi_fun, src);
