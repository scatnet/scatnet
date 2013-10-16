% DYADIC_FREQ_1D Compute center frequencies and bandwidths for the 1D Dyadic
%
% Usage
%	[psi_xi, psi_bw, phi_bw] = DYADIC_FREQ_1D(filt_opt)
%
% Input
%    filt_opt (struct): The parameters defining the filter bank. For example,
%       see SPLINE_FILTER_BANK_1D for details.
%
% Output
%    psi_xi (numeric): The center frequencies of the wavelet filters.
%    psi_bw (numeric): The bandwidths of the wavelet filters.
%    phi_bw (numeric): The bandwidth of the lowpass filter.
%
% Description
%    Compute the center frequencies and bandwidth for the wavelets and lowpass
%    filter of the one-dimensional dyadic filter bank, such as 
%    SPLINE_FILTER_BANK_1D.
%    
% See also
%    FILTER_FREQ, MORLET_FREQ_1D

function [psi_xi, psi_bw, phi_bw] = dyadic_freq_1d(filter_options)
	xi0 = 3*pi/4;

	psi_xi = xi0.*2.^(-[0:filter_options.J-1]);
	psi_bw = pi/2.*2.^(-[0:filter_options.J-1]);

	phi_bw = pi*2^(-[filter_options.J-1]);
end
