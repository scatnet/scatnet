function wavemod = wavemod_factory_2d(size_in, options)
% function wavemod = wavemod_factory_2d(size_in, options)
%
% builds wavelet modulus operator to be used by the generic 
% scattering scatt.m
%
% inputs :
% - size_in : <1x2 int> : size of the input of the scattering
% - options : [optional] <1x1 struct> containing the following optional options
%   - all the valid options fields for gabor_filter_bank_2d 
%   - nb_layer : <1x1 int> maximum scattering order (output will contains
%       all paths of length 0 <= m <= nb_layer)
%   - aa : <1x1 int> antialiasing (output will be oversampled by up to 2^aa)
%   - v : <1x1 double> number of voice per octave
%   - J : <1x1 int> maximum scale of wavelet will be a^J
%   - output_filters : <1x1 bool> if 1, output will contains filter bank
%
% output : 
% - propagators : <1x1 struct> containing fields :
%   - U : <1xM cell> of <function_handle> of wavelet-modulus operators 
%     to apply successively to the input image 
%   - A : <1x(M+1) cell> of <function_handle> of averaging operators
%     to apply after a sequence of U

options.null = 1;

filters = gabor_filter_bank_2d(size_in, options);

M = getoptions(options, 'M', 2); % maximum scattering order
aa = getoptions(options, 'aa', 0); % antialiasing
a = getoptions(options, 'a', 2);  % dilation factor of wavelets
J = numel(filters.psi{1}); % maximum scale of wavelet will be a^J

if (getoptions(options,'output_filters',0)) % output the filter bank if requested
  propagators.filters = filters;
end

% first layer
delta_j = 1/log2(a);
downsampler =  @(j)(max(floor(j/delta_j-aa), 0));

propagators.U{1} = @(x)(wavelet_modulus_2d(x, filters, downsampler));
propagators.A{1} = @(x)(lowpass_2d(x, filters, downsampler));

% 2+ layers
downsampler2 = @(nextj, lastres) (max(floor(nextj/delta_j)- lastres - aa, 0));
next_bands = @(lastj)(lastj + delta_j : delta_j : J - 1);

for m=2:M
  propagators.U{m} = @(previous_layer)...
    (wavelet_modulus_2d_layer(previous_layer, filters, downsampler2, next_bands));
  propagators.A{m} = @(previous_layer)...
    (lowpass_2d_layer(previous_layer, filters, downsampler2));
end

% last layer for output node
propagators.A{M+1} = @(previous_layer)...
        (lowpass_2d_layer(previous_layer, filters, downsampler2));

propagators.size_in = size_in;

end