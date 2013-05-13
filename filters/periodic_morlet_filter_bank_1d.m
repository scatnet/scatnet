% periodic_morlet_filter_bank_1d : Build a 1D morlet wavelets filter bank
% with very small support
% which will act on the rotation parameter
% in the roto-translation joint scattering
%
% Usage
%	filters = periodic_morlet_filter_bank_1d(N, K)
%
% Input
% - N : <1x1 int> number of sample, should be two times the number of
%   orientation of the 2d oriented wavelets
% - K : <1x1 int> maximum scale
%
% Output
% - filters : <1x1 struct> contains the following fields
%   - psi{l+1}: the fourier transform of high pass filter at scale 2^l
%   - phi     : the fourier transform of low pass filter

function filters = periodic_morlet_filter_bank_1d(N, K)
	
	sigma0 = 0.7;
	xi0 = 3*pi/4;
	res_max = floor(log2(N));
	
	% psi
	for k=0:K-1
		scale=2^k;
		sigma = sigma0 * scale;
		xi = xi0 / scale;
		filter = periodic_morlet_1d(N, sigma, xi);
		filterf = conj(fft(filter));

		filters.psi{k+1}.type = 'fourier_periodic_multires';
		filters.psi{k+1}.coefft{1} = filterf;
		for res = 1:res_max
			filters.psi{k+1}.coefft{res+1} = ...
				sum(reshape(filterf, [N/2^res, 2^res]), 2);
		end
	end
	
	% phi
	scale = 2^K;
	sigma = sigma0 * scale;
	filter = periodic_gaussian_1d(N, sigma);
	filterf = conj(fft(filter));
	
	filters.phi.type = 'fourier_periodic_multires';
	filters.phi.coefft{1} = filter;
	for res = 1:res_max
		filters.phi.coefft{res+1} = ...
			sum(reshape(filterf, [N/2^res, 2^res]), 2);
	end
	
end