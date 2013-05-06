function Wavelet = wavelet_factory_2d(size_in, options)

	% filters :
	filters = morlet_filter_bank_2d(size_in, options);
	
	% wavelet transforms :
	for m = 1:options.nb_layer
		Wavelet{m} = @(x)(wavelet_layer_2d(x, filters, options));
	end
	
end