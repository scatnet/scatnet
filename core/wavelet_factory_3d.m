function [ wavelet, filters, filters_rot ] = ...
		wavelet_factory_3d(size_in, options, options_rot)
	
	
	
	% filters along spatial variable
	options.null = 1;
	filters = morlet_filter_bank_2d(size_in, options);
	
	
	% filters along angular variable
	sz = filters.meta.nb_angle * 2; % nb_angle is between 0 and pi
	% periodic convolutions along angles
	options_rot.boundary = 'per';
	options_rot.filter_format = 'fourier_multires';
	options_rot.J = 3;
	options_rot.P = 0;
	filters_rot = morlet_filter_bank_1d(sz, options_rot);
	
	% number of layer
	options = fill_struct(options, 'nb_layer', 3);
	
	% first wavelet transform is an usual wavelet transform
	wavelet{1} = @(x)(wavelet_layer_2d(x, filters, options));
	
	% other wavelet transform are roto-translation wavelet
	for m = 2:options.nb_layer
		wavelet{m} = @(x)(wavelet_layer_3d(x, filters, filters_rot, options));
	end
	
	
end

