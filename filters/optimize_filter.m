function filter = optimize_filter(filter_f,lowpass,options)
	options = fill_struct(options,'truncate_threshold',1e-3);
	options = fill_struct(options,'filter_format','fourier_multires');

	if strcmp(options.filter_format,'fourier')
		filter = filter_f;
	elseif strcmp(options.filter_format,'fourier_multires')
		filter = periodize_filter(filter_f);
	elseif strcmp(options.filter_format,'fourier_truncated')
		filter = truncate_filter(filter_f,options.truncate_threshold,lowpass);
	else
		error(sprintf('Unknown filter format ''%s''',options.filter_format));
	end
end
