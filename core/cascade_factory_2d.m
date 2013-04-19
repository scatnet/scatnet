function cascade = cascade_factory_2d(size_in, options)

options = fill_struct(options, 'J', 4);
options = fill_struct(options, 'antialiasing', 1);
options = fill_struct(options, 'v', 1);
options = fill_struct(options, 'nb_layer', 3);

% padding and unpadding: 
default_margin = ...
  2^max(floor(options.J/options.v - options.antialiasing),0) * [1,1];

margin_in = getoptions(options, 'margin_in', default_margin);
margin_out = getoptions(options, 'margin_out', default_margin);

cascade.pad = @(x)(padd_mirror_layer_2d(x, margin_in));
size_padded = size_in + 2*margin_in;
cascade.unpad = @(x)(unpadd_layer_2d(x, size_padded, margin_out));

% filters : 
filters = morlet_filter_bank_2d(size_padded, options);

% wavelet transforms : 
for m = 1:options.nb_layer
  cascade.wavelet{m} = @(x)(wavelet_layer_2d(x, filters, options));
end

% modulus :
for m = 1:options.nb_layer
  cascade.modulus{m} = @(x)(modulus_layer(x));
end


