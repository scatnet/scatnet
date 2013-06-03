function wavelet = joint_tf_wavelet_factory_1d(N, time_filter_options, freq_filter_options, scat_options, M)
	time_filters = filter_bank(N, time_filter_options);
	
	N_freq = 2^ceil(log2(numel(time_filters{1}.psi.filter)));
	
	freq_filters = filter_bank(N_freq, freq_filter_options);
	
	scat_options1 = scat_options;
	scat_options1.phi_renormalize = 0;
	wavelet{1} = @(X)(wavelet_layer_1d(X, time_filters{1}, scat_options1));
	
	for m = 1:M
		time_filt_ind = min(numel(time_filters), m+1);
		freq_filt_ind = min(numel(freq_filters), m+1);
		wavelet{m+1} = @(X)(joint_tf_wavelet_layer_1d(X, {freq_filters{freq_filt_ind}, time_filters{time_filt_ind}}, scat_options));
	end
end