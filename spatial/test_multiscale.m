x = draw_circle([256,256], [128,128], 32, 2);
%%
x = zeros([512,512]);
x(10,10) = 1;
x = real(ifft2(x));
x = x./max(x(:));
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
renorm = @(x)(scatfun(@(x)(log(x+1E-20)), x));
renorm_ms = @(x)(cellfun_monitor(renorm, x));

Sx_renorm = renorm_ms(Sx);
%%

vec = @(x)(mean(mean(remove_margin(format_scat(x),1),2),3));
vec_ms = @(x)(cellfun_monitor(vec, x));
Sx_spat_avg = vec_ms(Sx_renorm);
sx_spat_avg = cell2mat(Sx_spat_avg);
plot(sx_spat_avg);
legend('1','2','3','4');