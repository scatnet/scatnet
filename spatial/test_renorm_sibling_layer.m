%% simple example of use of renorm_sibling_layer
%% compute scattering
clear; close all;
Wop = wavelet_factory_2d_pyramid();
x = uiuc_sample;
Sx = scat(x, Wop);
%% extract the second layer
layer = Sx{3};
op = @(x)(sum(x,3));

%% to renormalized order 2, the sibling is all the node with same ancestor
sibling = @(p)(find(Sx{3}.meta.j(1,:) == Sx{3}.meta.j(1,p) & ...
    Sx{3}.meta.theta(1,:) == Sx{3}.meta.theta(1,p)));

%% renormalize
layer_renorm = renorm_sibling_layer(layer, op, sibling);

%% more sophistated example of use of renorm_sibling_layer
%% smooth a bit + L1 norm instead of just L1 norm
options.sigma_phi = 1;
options.P = 4;
filters = morlet_filter_bank_2d_spatial(options);
h = filters.h.filter;
smooth = @(x)(conv_sub_2d(x, h, 0));
op = @(x)(smooth(sum(x,3)));

%% renormalize
layer_renorm = renorm_sibling_layer(layer, op, sibling);

%% display
figure(1);
image_scat_layer(layer, 0, 0);
title('second order of scattering')
figure(2);
image_scat_layer(layer_renorm, 0, 0);
title('normalized second order of scattering')
