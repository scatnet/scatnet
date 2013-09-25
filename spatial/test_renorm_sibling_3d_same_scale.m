%% simple example of use of renorm_sibling_3d_same_scale
clear; close all;
x = uiuc_sample;
%% compute roto-translation scattering of an image
options.Q = 1;
options.J = 5;
Wop = wavelet_factory_3d_spatial(options, options, options);
Sx = scat(x, Wop);

%% L1 renormalization
op = @(x)(sum(x, 3));
Sx_renorm = renorm_sibling_3d_same_scale(Sx, op);

%% L1 + smoothing renormalization
op = renorm_factory_L1_smoothing(2);
[Sx_renorm, siblings] = renorm_sibling_3d_same_scale(Sx, op);

%%
image_scat(Sx, 0, 0);
%%
image_scat(Sx_renorm, 0, 0);
%%
close all;
imagesc(min(image_scat_layer(Sx_renorm{3},0,0),0.2));

%%
image_scat(Sx_renorm, 1, 1);
%%
image_scat(Sx, 1, 1);
