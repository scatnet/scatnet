clear;
x = lena;
opt_filters.P = 2;

K = 10;
filters = morlet_filter_bank_2d_pyramid(opt_filters);

opt_wav.J = 5;
tic;
for k = 1:K
	[x_phi, x_psi, meta_phi, meta_psi] = wavelet_2d_pyramid(x, filters, opt_wav);
end
toc;
vx.signal = x_psi;
vx.meta = meta_psi;
ux = modulus_layer(vx);
img = image_scat_layer(ux);
immac(img);

%%
clear;
x = lena;
filt_opt.J = 5;
scat_opt.oversampling = 0;
options.L = 8;
K = 10;
[w,filters] = wavelet_factory_2d(size(x), filt_opt, scat_opt);

U{1}.signal{1} = x;
U{1}.meta.j = zeros(0,1);
tic;
for k = 1:K
	[ax,wx] = w{1}(U{1});
end
toc;
ux = modulus_layer(wx);
img = image_scat_layer(ux);
immac(img,2);
%%
