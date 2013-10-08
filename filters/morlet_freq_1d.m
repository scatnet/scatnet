% MORLET_FREQ_1D Compute a bank of one-dimensional, Morlet wavelet
%   filters in the Fourier domain.
%
% Usage
%	filters = morlet_freq_1d(filt_opt)
%
% Input
%    filt_opt (struct): Options of the bank of filters. The fields
%     used by MORLET_FREQ_1D are the following :
%       J (int): The number of logarithmically spaced wavelets. For  
%          Q=1, this corresponds to the total number of wavelets since there 
%          are no  linearly spaced ones. Together with Q, this controls the  
%          maximum extent the mother wavelet is dilated to obtain the rest of 
%          the filter bank. Specifically, the largest filter has a bandwidth
%          2^(J/Q) times that of the mother wavelet (default 
%          T_to_J(sz, options)).
%       Q (int): The number of wavelets per octave (default 1).
%       xi_psi: vector of center frequencies of logarithmically spaced,
%          band-pass filters
%       sigma_psi: vector of standard deviations of band-pass filters
%       sigma_phi: vector of standard deviations of low-pass filters
%
%
% Output
%    xi_psi: vector of center frequencies of band-pass filters
%    bw_psi: vector of bandwidths of band-pass filters
%    bw_phi: bandwidth of low-pass filter
%
% Description
%    Compute the Morlet filter bank in the Fourier domain.

function [xi_psi,bw_psi,bw_phi] = morlet_freq_1d(filt_opt)
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
    
    % Calculate band-pass filter
	sigma_phi = filt_opt.sigma_phi * 2^((filt_opt.J-1)/filt_opt.Q);

	% Convert (spatial) sigmas to (frequential) bandwidths
	bw_psi = pi/2 * sigma0./sigma_psi;
	if ~filt_opt.phi_dirac
		bw_phi = pi/2 * sigma0./sigma_phi;
	else
		bw_phi = 2 * pi;
	end
end
