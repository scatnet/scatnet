% FILTER_FREQ Calculate center frequencies and bandwidths
%
% Usage
%    [psi_xi, psi_bw, phi_bw] = FILTER_FREQ(filter_options)
%
% Input
%    filter_options (struct): The parameters defining the filter bank.
%
% Output
%    psi_xi (numeric): The center frequencies of the wavelet filters.
%    psi_bw (numeric): The bandwidths of the wavelet filters.
%    phi_bw (numeric): The bandwidth of the lowpass filter.


function [psi_xi, psi_bw, phi_bw] = filter_freq(filter_options)
	if strcmp(filter_options.filter_type,'spline_1d')
		[psi_xi,psi_bw,phi_bw] = spline_freq_1d(filter_options);
	elseif strcmp(filter_options.filter_type,'morlet_1d') || ...
		strcmp(filter_options.filter_type,'gabor_1d')
		[psi_xi,psi_bw,phi_bw] = morlet_freq_1d(filter_options);
	else
		error(sprintf('Unknown filter type ''%s''', ...
			filter_options.filter_type));
	end
end
