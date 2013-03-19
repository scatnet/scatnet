function propagators = propagators_builder_3d(size_in,options)
options.null = 1;


aa = getoptions(options,'aa',0); % anti aliasing
aa_rot = getoptions(options,'aa_rot',1); % anti aliasing for rotation filtering
options.L = getoptions(options,'L',8); % change default number of

filters = gabor_filter_bank_2d(size_in,options);
a = filters.infos.a;
J = numel(filters.psi{1});

filters_rotation = tiny_wavelets(2*options.L, 3);

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

% lowpass along all spatial + rotation parameters
propagators.A{2} = @(x)(lowpass_3d_layer(x,filters,downsampler3,options));
propagators.A{3} = @(x)(lowpass_3d_layer(x,filters,downsampler3,options));