% load an image
x = uiuc_sample;
x = x(1:256, 1:256);

% compute propagators
size_in = size(x);
propagators = propagators_builder_3d(size_in);

% compute scattering
[S, U] = gscatt(x, propagators);