% morlet_filter_bank_1d: Creates a Morlet/Gabor filter bank.
% Usage
%    filters = morlet_filter_bank_1d(sz, options)
% Input
%    sz: The size of the input data.
%    options (optional): Filter parameters.
% Output
%    filters: The Morlet/Gabor filter bank corresponding to the data size sz
%       and the filter parameters in options.
% Description
%    Depending on the value of options.filter_type, the functions either
%    creates a Morlet filter bank (for filter_type 'morlet_1d') or a Gabor
%    filter bank (for filter_type 'gabor_1d'). The former is obtained from 
%    the latter by, for each filter, subtracting a constant times its enve-
%    lopes uch that the mean of the resulting function is zero.
%
%    The following parameters can be specified in options:
%       options.filter_type: See above (default 'morlet_1d').
%       options.Q: The number of wavelets per octave (default 1).
%       options.B: The reciprocal per-octave bandwidth of the wavelets 
%          (default Q).
%       options.J: The number of logarithmically spaced wavelets. For Q=1, 
%          this corresponds to the total number of wavelets since there are no 
%          linearly spaced ones. Together with Q, this controls the maximum 
%          extent the mother wavelet is dilated to obtain the rest of the
%          filter bank. Specifically, the largest filter has a bandwidth
%          2^(J/Q) times that of the mother wavelet (default 
%          T_to_J(sz, options)).
%       options.phi_bw_multiplier: The ratio between the bandwidth of the 
%          lowpass filter phi and the lowest-frequency wavelet (default 2 if
%          Q = 1, otherwise 1).
%       options.boundary, options.precision, and options.filter_format: 
%          See documentation for filter_bank function.

function filters = morlet_filter_bank_1d(sig_length,options)
	if nargin < 2
		options = struct();
	end
	
	parameter_fields = {'filter_type','Q','B','J','P','xi_psi', ...
		'sigma_psi', 'sigma_phi', 'boundary', 'phi_dirac'};
	
	% If we are given a two-dimensional size, take first dimension
	sig_length = sig_length(1);
	
	sigma0 = 2/sqrt(3);
	
	% Fill in default parameters
	options = fill_struct(options, ...
		'filter_type','morlet_1d');
	options = fill_struct(options, ...
		'Q', 1);
	options = fill_struct(options, ...
		'B', options.Q);
	options = fill_struct(options, ...
		'xi_psi',1/2*(2^(-1/options.Q)+1)*pi);
	options = fill_struct(options, ...
		'sigma_psi',1/2*sigma0/(1-2^(-1/options.B)));
	options = fill_struct(options, ...
		'phi_bw_multiplier', 1+(options.Q==1));
	options = fill_struct(options, ...
		'sigma_phi', options.sigma_psi/options.phi_bw_multiplier);
	options = fill_struct(options, ...
		'J', T_to_J(sig_length, options));
	options = fill_struct(options, ...
		'P', round((2^(-1/options.Q)-1/4*sigma0/options.sigma_phi)/ ...  ...
			(1-2^(-1/options.Q))));
	options = fill_struct(options, ...
		'precision', 'double');
	options = fill_struct(options, ...
		'filter_format', 'fourier_truncated');
	options = fill_struct(options, ...
		'boundary', 'symm');
	options = fill_struct(options, ...
		'phi_dirac', 0);
	
	if ~strcmp(options.filter_type,'morlet_1d') && ...
			~strcmp(options.filter_type,'gabor_1d')
		error('Filter type must be ''morlet_1d'' or ''gabor_1d''.');
	end
	
	do_gabor = strcmp(options.filter_type,'gabor_1d');
	
	filters = struct();
	
	% Copy filter parameters into filter structure. This is needed by the
	% scattering algorithm to calculate sampling, path space, etc.
	filters.meta = struct();
	for l = 1:length(parameter_fields)
		filters.meta = setfield(filters.meta,parameter_fields{l}, ...
			getfield(options,parameter_fields{l}));
	end
	
	% The normalization factor for the wavelets, calculated using the filters
	% at the finest resolution (N)
	psi_ampl = 1;
	
	if (strcmp(options.boundary, 'symm'))
		N = 2*sig_length;
	else
		N = sig_length;
	end
	
	N = 2^ceil(log2(N));
	
	filters.meta.size_filter = N;
	
	filters.psi.filter = cell(1,options.J+options.P);
	filters.phi = [];
	
	[psi_center,psi_bw,phi_bw] = morlet_freq_1d(filters);
	
	psi_sigma = sigma0*pi/2./psi_bw;
	phi_sigma = sigma0*pi/2./phi_bw;
	
	% Calculate normalization of filters so that sum of squares does not
	% exceed 2. This guarantees that the scattering transform is
	% contractive.
	S = zeros(N,1);
	
	% As it occupies a larger portion of the spectrum, it is more
	% important for the logarithmic portion of the filter bank to be
	% properly normalized, so we only sum their contributions.
	for j1 = 0:options.J-1
		temp = gabor(N,psi_center(j1+1),psi_sigma(j1+1),options.precision);
		if ~do_gabor
			temp = morletify(temp,psi_sigma(j1+1));
		end
		S = S+abs(temp).^2;
	end
	
	psi_ampl = sqrt(2/max(S));
	
	% Apply the normalization factor to the filters.
	for j1 = 0:length(filters.psi.filter)-1
		temp = gabor(N,psi_center(j1+1),psi_sigma(j1+1),options.precision);
		if ~do_gabor
			temp = morletify(temp,psi_sigma(j1+1));
		end
		filters.psi.filter{j1+1} = optimize_filter(psi_ampl*temp,0,options);
		filters.psi.meta.k(j1+1,1) = j1;
	end
	
	% Calculate the associated low-pass filter
	if ~options.phi_dirac
		filters.phi.filter = gabor(N, 0, phi_sigma, options.precision);
	else
		filters.phi.filter = ones(N,1,options.precision);
	end
	
	filters.phi.filter = optimize_filter(filters.phi.filter,1,options);
	filters.phi.meta.k(1,1) = options.J+options.P;
end

function f = gabor(N,xi,sigma,precision)
	extent = 1;         % extent of periodization - the higher, the better
	
	sigma = 1/sigma;
	
	f = zeros(N,1,precision);
	
	% Calculate the 2*pi-periodization of the filter over 0 to 2*pi*(N-1)/N
	for k = -extent:1+extent
		f = f+exp(-(([0:N-1].'-k*N)/N*2*pi-xi).^2./(2*sigma^2));
	end
end

function f = morletify(f,sigma)
	f0 = f(1);
	
	f = f-f0*gabor(length(f),0,sigma,class(f));
end
