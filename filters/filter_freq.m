function [psi_xi,psi_bw,phi_bw] = filter_freq(filters)
	if strcmp(filters.filter_type,'spline_1d')
		[psi_xi,psi_bw,phi_bw] = spline_1d_freq(filters);
	elseif strcmp(filters.filter_type,'morlet_1d') || ...
		strcmp(filters.filter_type,'gabor_1d')
		[psi_xi,psi_bw,phi_bw] = morlet_1d_freq(filters);
	else
		error(sprintf('Unknown filter type ''%s''',filters.filter_type))
	end
end
