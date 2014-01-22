% MORLET_FREQ_1D Compute center frequencies and bandwidths for the 1D Morlet
%
% Usage
%	[psi_xi, psi_bw, phi_bw] = MORLET_FREQ_1D(filt_opt)
%
% Input
%    filt_opt (struct): The parameters defining the filter bank. See 
%       MORLET_FILTER_BANK_1D for details.
%
% Output
%    psi_xi (numeric): The center frequencies of the wavelet filters.
%    psi_bw (numeric): The bandwidths of the wavelet filters.
%    phi_bw (numeric): The bandwidth of the lowpass filter.
%
% Description
%    Compute the center frequencies and bandwidth for the wavelets and lowpass
%    filter of the one-dimensional Morlet/Gabor filter bank.
% 
% See also
%    FILTER_FREQ, DYADIC_FREQ_1D

function [xi_psi, bw_psi, bw_phi] = morlet_freq_1d(filt_opt)
	sigma0 = 2/sqrt(3);
	
	% Calculate logarithmically spaced, band-pass filters.
    xi_psi = filt_opt.xi_psi * 2.^((0:-1:1-filt_opt.J)/filt_opt.Q);
    sigma_psi = filt_opt.sigma_psi * 2.^((0:filt_opt.J-1)/filt_opt.Q);

	% Calculate linearly spaced band-pass filters so that they evenly
	% cover the remaining part of the spectrum
	step = pi * 2^(-filt_opt.J/filt_opt.Q) * ...
        (1-1/4*sigma0/filt_opt.sigma_phi*2^(1/filt_opt.Q))/filt_opt.P;
    xi_psi(filt_opt.J+1:filt_opt.J+filt_opt.P) = filt_opt.xi_psi * ...
        2^((-filt_opt.J+1)/filt_opt.Q) - step * (1:filt_opt.P);
    sigma_psi(filt_opt.J+1:filt_opt.J+1+filt_opt.P) = ...
        filt_opt.sigma_psi*2^((filt_opt.J-1)/filt_opt.Q);
    
    % Calculate low-pass filter
	sigma_phi = filt_opt.sigma_phi * 2^((filt_opt.J-1)/filt_opt.Q);

	% Convert (spatial) sigmas to (frequential) bandwidths
	bw_psi = pi/2 * sigma0./sigma_psi;
	if ~filt_opt.phi_dirac
		bw_phi = pi/2 * sigma0./sigma_phi;
	else
		bw_phi = 2 * pi;
	end
end
