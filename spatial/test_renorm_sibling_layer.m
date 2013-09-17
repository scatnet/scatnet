Wop = wavelet_factory_2d_spatial();
x = uiuc_sample;
Sx = scat(x, Wop);
%%
layer = Sx{3};
op = @(x)(sum(x,3));
%% smooth a bit
options.sigma_phi = 1;
options.P = 4;
filters = morlet_filter_bank_2d_spatial(options);
h = filters.h.filter;
sum(h)
smooth = @(x)(convsub2d_spatial(x, h, 0));

op = @(x)(smooth(sum(x,3)));
%%

% to renormalized order 2, the sibling is all the node with same ancestor
sibling = @(p)(find(Sx{3}.meta.j(1,:) == Sx{3}.meta.j(1,p) & ...
    Sx{3}.meta.theta(1,:) == Sx{3}.meta.theta(1,p)));

layer_renorm = renorm_sibling_layer(layer, op, sibling);

figure(1);
image_scat_layer(layer, 0, 0);
figure(2);
image_scat_layer(layer_renorm, 0, 0);