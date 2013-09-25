clear;
x = uiuc_sample;
options.P = 2;
options.J = 5;
K = 10;
filters = morlet_filter_bank_2d_pyramid(options);

tic;
for k = 1:K
	[x_phi, x_psi] = wavelet_2d_pyramid(x, filters, options);
end
toc;
ux = modulus_layer(x_psi);
img = image_scat_layer(ux);
immac(img);

%%
clear;
x = uiuc_sample;
options.J = 5;
options.oversampling = 0;
options.L = 8;
K = 10;
[w,filters] = wavelet_factory_2d(size(x), options, options);

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
