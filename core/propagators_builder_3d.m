function propagators = propagators_builder_3d(size_in,options)
% function propagators = propagators_builder_3d(size_in,options)
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
%   - aa_rot : <1x1 int> inner antialiasing on the rotation parameter
%   (internal nodes U will be oversampled by up to 2^aa_rot, scattering
%   nodes S will be fully rotation averaged)
%   - a : <1x1 double> dilation factor of wavelets
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

aa = getoptions(options,'aa',0); % anti aliasing
aa_rot = getoptions(options,'aa_rot',1); % anti aliasing for rotation filtering
options.L = getoptions(options,'L',8); % number of orientation

filters = gabor_filter_bank_2d(size_in,options); % the spatial filter bank
a = filters.infos.a;
J = numel(filters.psi{1});


filters_rotation = tiny_wavelets(2*options.L, 3); % the filter bank along rotation

if (getoptions(options,'output_filters',0)) % output the filter bank if requested
  propagators.filters = filters;
  propagators.filters_rotation = filters_rotation;
end

% first layer : spatial wavelet + modulus
delta_j = 1/log2(a);
downsampler =  @(j)(max(floor(j/delta_j-aa),0));

propagators.U{1} = @(x)(wavelet_modulus_2d(x,filters,downsampler,options));
propagators.A{1} = @(x)(lowpass_2d(x,filters,downsampler,options));

% second layer : joint spatial-rotation wavelet + modulus
downsampler2 = @(nextj,lastres) (min(max( floor(nextj/delta_j - lastres - aa), 0),numel(filters.phi)-lastres-1));
downsampler3 = @(nextj, lastres) ( max(floor(nextj/delta_j )- lastres - aa,0));

downsampler_rotation = @(j_rot) (max( j_rot - aa_rot, 0));
next_bands = @(lastj)(lastj + 1:delta_j:J - 1);

propagators.U{2} = @(x)wavelet_modulus_3d(x, filters, filters_rotation, ...
  downsampler2, downsampler_rotation , ...
  next_bands, options );

propagators.A{2} = @(x)(lowpass_3d_layer(x,filters,downsampler3,options));
propagators.A{3} = @(x)(lowpass_3d_layer(x,filters,downsampler3,options));