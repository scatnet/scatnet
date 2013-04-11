function filter = optimize_filter(filter_f,lowpass,options)
	options = fill_struct(options,'truncate_threshold',1e-3);
	
	if strcmp(options.optimize,'fourier')
		filter = filter_f;
	elseif strcmp(options.optimize,'fourier_multires')
		filter = periodize_filter(filter_f);
	elseif strcmp(options.optimize,'fourier_truncated')
		filter = truncate_filter(filter_f,options.truncate_threshold,lowpass);
	else
		error(sprintf('Unknown filter optimization type ''%s''',options.optimize))
	end
end
