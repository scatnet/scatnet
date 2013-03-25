% load an image
x = uiuc_sample;
size_in = size(x);

% compute filters
filters = gabor_filter_bank_2d(size_in);

% downsample
downsampler = @(j)(j);

% compute wavelet transform
out = wavelet_modulus_2d(x, filters, downsampler);

% display all channel in a big image
bigimg = display_gscatt_all(out);
imagesc(bigimg);
colormap gray;