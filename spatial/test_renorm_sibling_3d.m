%% simple example of use of renorm_sibling_3d
clear; close all;

%% compute roto-translation scattering of an image
x = lena;
Wop = wavelet_factory_3d_spatial();
Sx = scat(x, Wop);

%% L1 renormalization
op = @(x)(sum(x, 3));
Sx_renorm = renorm_sibling_3d(Sx, op);

%% L1 + smoothing renormalization
op = renorm_factory_L1_smoothing(2);
Sx_renorm = renorm_sibling_3d(Sx, op);

%%
image_scat(Sx_renorm, 0, 0);
