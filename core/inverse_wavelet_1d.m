function x = inverse_wavelet_1d(N0, x_phi, x_psi, meta_phi, meta_psi, ...
	dual_filters, options)
	
	if length(N0)>1
		error('Only 1D for the moment!')
	end
	
	temp = zeros(N0,1);
	
	N0_padded = dual_filters.N;

	N_padded = dual_filters.N/2^meta_phi.resolution;
	x_phi = pad_signal(x_phi, N_padded, dual_filters.boundary);
	
	x_phi = interpft(x_phi, N0_padded)/2^(meta_phi.resolution/2);
	
	x = conv_sub_1d(fft(x_phi), dual_filters.phi.filter, 0);
	
	for k = 1:length(x_psi)
		if isempty(x_psi{k})
			continue;
		end
		
		N_padded = dual_filters.N/2^meta_psi.resolution(k);
		x_psi{k} = pad_signal(x_psi{k}, N_padded, dual_filters.boundary);

		x_psi{k} = interpft(x_psi{k}, N0_padded)/2^(meta_psi.resolution(k)/2);
		
		x = x+conv_sub_1d(fft(x_psi{k}), dual_filters.psi.filter{k}, 0);
	end
	
	x = real(x);
	
	x = unpad_signal(x, 0, N0);
end