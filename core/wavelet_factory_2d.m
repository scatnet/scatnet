function [Wavelet, filters] = wavelet_factory_2d(size_in, options)
	options.null = 1;
	options = fill_struct(options, 'nb_layer', 3);
	
	
	
	% filters :
	filters = morlet_filter_bank_2d(size_in, options);
	
	% wavelet transforms :
	for m = 1:options.nb_layer
		Wavelet{m} = @(x)(wavelet_layer_2d(x, filters, options));
	end
	
	
	
end