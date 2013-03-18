function propagators = propagators_builder_2d(size_in, options)
% function propagators = propagators_builder_2d(size_in, options)
%
% builds propagators to be used by the generic scattering gscatt.m
%
% inputs :
% - size_in : <1x2 int> : size of the input of the scattering
% - options : [optional] <1x1 struct> containing the following optional options
%   - all the valid options fields for gabor_filter_bank_2d 
%   - M : <1x1 int> maximum scattering order (output will contains
%       all paths of length 0 <= m <= M)
%   - aa : <1x1 int> antialiasing (output will be oversampled by up to 2^aa)
%   - a : <1x1 double> dilation factor of wavelets
%   - J : <1x1 int> maximum scale of wavelet will be a^J
%   - output_filters : <1x1 bool> if 1, output will contains filter bank
%
% outputs : 
%

options.null = 1;
M = getoptions(options,'M',2); % maximum scattering order
aa = getoptions(options,'aa',0); % anti aliasing
a = getoptions(options,'a',2); 

filters = gabor_filter_bank_2d(size_in,options);
J = numel(filters.psi{1});



if (getoptions(options,'output_filters',0)) % output the filter bank if requested
  propagators.filters = filters;
end


% first layer
delta_j = 1/log2(a);
downsampler =  @(j)(max(floor(j/delta_j-aa), 0));

propagators.U{1} = @(x)(wavelet_modulus_2d(x, filters, downsampler));
propagators.A{1} = @(x)(lowpass_2d(x, filters, downsampler));

% 2+ layers
%downsampler2 = @(nextj,lastres) (max( nextj - lastres - aa, 0));
downsampler2 = @(nextj, lastres) ( max(floor(nextj/delta_j )- lastres - aa,0));
next_bands = @(lastj)(lastj + delta_j:delta_j:J - 1);

for m=2:M
  propagators.U{m} = @(previous_layer)(wavelet_modulus_2d_layer(previous_layer,...
    filters,downsampler2,next_bands));
  propagators.A{m} = @(previous_layer)(lowpass_2d_layer(previous_layer,filters,downsampler2));
end
% last layer for output node
propagators.A{M+1} = @(previous_layer)(lowpass_2d_layer(previous_layer,filters,downsampler2));


propagators.size_in = size_in;
  



end