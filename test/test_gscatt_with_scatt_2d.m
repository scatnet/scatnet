% load an image
x = uiuc_sample;

% compute propagators
size_in = size(x);
propagators = propagators_builder_2d(size_in);

% compute scattering
[S, U] = gscatt(x, propagators);