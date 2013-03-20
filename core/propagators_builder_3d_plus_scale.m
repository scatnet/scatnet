function propagators = propagators_builder_3d_plus_scale(size_in,options)
% july 13 2012 - laurent sifre
% FUNCTION BUILDER FOR GENERIC SCATTERING
% this function builds a family of propagator
% indexed by the scattering order to be used by gscatt.m
% the first U computes wavelet transform
% second U computes wavelet transform with only required nodes
% only two layers for now
options.null = 1;

aa = getoptions(options,'aa',0); % anti aliasing

aa_rot = getoptions(options,'aa_rot',1); % anti aliasing for rotation filtering






Jbar = getoptions(options,'J',9);
% for scale original 0 2 4 6 8 
delta_J_max = getoptions(options, 'delta_J_max', 4);
% for dscale 0 1 2 3 
J = Jbar + delta_J_max - 1;
% for scale 0:11 = 12 different scales
a = getoptions(options, ' a', sqrt(2));
options_filters.a = a;
options_filters.sigma0 = getoptions(options, 'sigma0', 1);
options_filters.L = getoptions(options, 'L', 8);
options_filters.sigma00 = getoptions(options, 'sigma00', 1.5);
options_filters.slant = getoptions(options,'slant', 1);
options_filters.xi0 = getoptions(options, 'xi0', 3*pi/4);
if (isfield(options,'gab_type'))
  options_filters.gab_type = options.gab_type;
end
options_filters.J = J;

filters = gabor_filter_bank_2d_all_low_pass(size_in, options_filters);


if (getoptions(options,'output_filters',0)) % output the filter bank if requested
  propagators.filters = filters;
end


% first layer
delta_j = 1/log2(a);
downsampler =  @(j)(max(floor(j/delta_j-aa),0));

propagators.U{1} = @(x)(wavelet_modulus_2d(x,filters,downsampler,options));
propagators.A{1} = @(x)(lowpass_2d(x,filters,downsampler,options));

% second layer

% spatial stuff
downsampler2 = @(nextj,lastres) (max( floor(nextj/delta_j - lastres - aa), 0));
offset_j_min = 1/log2(a);
next_bands =  @(j)(next_bands_4d(j,J ,offset_j_min, delta_j, delta_J_max));
next_bands_lp = @(j)(next_bands_4d_lowpass(j,J, 1,delta_j, delta_J_max));

% rotation stuff
filters_rotation = tiny_wavelets(2*options_filters.L,3);
downsampler_rotation = @(j_rot) (max( j_rot - aa_rot, 0));
if (getoptions(options,'output_filters',0)) % output the filter bank if requested
  propagators.filters_rotation = filters_rotation;
end



propagators.U{2} = @(x)wavelet_modulus_3d_lowpass_plus_scale(x, filters, filters_rotation, ...
    downsampler2, downsampler_rotation , ...
    next_bands,next_bands_lp, options );
  
propagators.A{2} = @(x)(lowpass_3d_layer_only_angle(x,options));
propagators.A{3} = @(x)(lowpass_3d_layer_only_angle(x,options));

%propagators.U{2} = @(previous_layer)(wavelet_modulus_2d_layer(previous_layer,...
%  filters,downsampler2,next_bands));
%propagators.A{2} = @(previous_layer)(lowpass_2d_layer(previous_layer,filters,downsampler2));


%propagators.A{3} = @(previous_layer)(lowpass_2d_layer(previous_layer,filters,downsampler2));

propagators.info.delta_j = delta_j;
propagators.info.offset_j_min = offset_j_min;
propagators.info.delta_J_max = delta_J_max;
propagators.info.Jbar = Jbar;






end