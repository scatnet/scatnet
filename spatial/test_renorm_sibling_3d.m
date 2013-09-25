%% simple example of use of renorm_sibling_3d
clear; close all;
x = lena;
%% compute roto-translation scattering of an image
options.Q = 2;
Wop = wavelet_factory_3d_spatial(options, options, options);
Sx = scat(x, Wop);

%% L1 renormalization
op = @(x)(sum(x, 3));
Sx_renorm = renorm_sibling_3d(Sx, op);

%% L1 + smoothing renormalization
op = renorm_factory_L1_smoothing(1);
[Sx_renorm, siblings] = renorm_sibling_3d(Sx, op);

%%
image_scat(Sx, 0, 0);
%%
image_scat(Sx_renorm, 0, 0);
%%
close all;
imagesc(log(image_scat_layer(Sx{3},0,1)+0.001));

%%
image_scat(Sx_renorm, 1, 1);
%%
image_scat(Sx, 1, 1);
