x = draw_circle([256,256], [128,128], 32, 2);

%% spatial
src = uiuc_src;
options.J = 3;
options.Q = 1;
options.M = 2;

options.parallel = 0;
Wop = wavelet_factory_3d_spatial(options, options,options);
%fun = @(filename)(scat(imreadBW(filename), Wop));
fun = @(x)(scat(x, Wop));
multi_fun = @(x)(fun_multiscale(fun, x, sqrt(2), 4));
[Sx, xms] = multi_fun(x);
%%
renorm = @(x)(scatfun(@log, x));
renorm_ms = @(x)(cellfun_monitor(renorm, x));

vec = @(Sx)(mean(mean(remove_margin(format_scat(Sx),1),2),3));
vec_ms = @(x)(cellfun_monitor(vec, x));
Sx_spat_avg = vec_ms(Sx)