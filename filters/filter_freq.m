% FILTER_FREQ Calculate center frequencies and bandwidths
%
% Usage
%    [psi_xi, psi_bw, phi_bw] = FILTER_FREQ(filt_opt)
%
% Input
%    filt_opt (struct): The parameters defining the filter bank.
%
% Output
%    psi_xi (numeric): The center frequencies of the wavelet filters.
%    psi_bw (numeric): The bandwidths of the wavelet filters.
%    phi_bw (numeric): The bandwidth of the lowpass filter.
%
% Description
%    Called by WAVELET_1D and WAVELET_LAYER_1D, this function provides the
%    center frequency and bandwidth of a mother wavelet, whose parameters
%    are specified in filt_opt. It operates as a mere disjunction between
%    SPLINE_FREQ_1D, and MORLET_FREQ_1D.
%
% See also
%   MORLET_FREQ_1D, SPLINE_FREQ_1D, WAVELET_1D, WAVELET_LAYER_1D

function [psi_xi, psi_bw, phi_bw] = filter_freq(filter_options)
	if strcmp(filter_options.filter_type,'spline_1d')
		[psi_xi,psi_bw,phi_bw] = dyadic_freq_1d(filter_options);
	elseif strcmp(filter_options.filter_type,'morlet_1d') || ...
		strcmp(filter_options.filter_type,'gabor_1d')
		[psi_xi,psi_bw,phi_bw] = morlet_freq_1d(filter_options);
	else
		error('Unknown filter type ''%s''', filter_options.filter_type);
	end
end
