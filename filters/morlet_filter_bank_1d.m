%TODO redo doc
%MORLET_FILTER_BANK Calculates a Morlet/Gabor filter bank
%   filters = morlet_filter_bank(sig_length,options) generates a Morlet or
%   Gabor filter bank for signals of length sig_length using parameters
%   contained in options. If the number of wavelets per octave specified
%   exceeds 1, the convential (logarithimically spaced, constant-Q) wavelets
%   will be supplemented by linarly spaced, contant-bandwidth filters in
%   the low frequencies in order to adequately cover the frequency domain
%   without increasing the temporal support of the filters.
%
%   The following options can be specified:
%      options.Q - The number of wavelets per octave at critical sampling in
%         frequency. [Default 1]
%      options.a - The dilation factor between adjacent wavelets. The factor
%         2^(1/Q) corresponds to critical sampling. More redundant frequency
%         sampling can be obtained by decreasing a. [Default 2^(1/Q)]
%      options.J - The number of logarithmically spaced wavelets. This
%         controls the minimum frequency bandwidth of the wavelets and
%         consequently the maximum temporal bandwidth. For a filter bank
%         with parameters Q, a, J, the maximum temporal bandwidth is Q*a^J.
%         [Default log(sig_length/Q)/log(a)]
%      options.gabor - If 0, Morlet wavelets are used, whereas if 1, Gabor
%         filters are used. Since the former have a vanishing moment, they are
%         highly recommended. For audio signals, however, energy at very low
%         frequencies is often small, so Gabor filters can be used in the
%         first-order filter bank. [Default 0]
%      options.precision - The precision, 'double' or 'single', used to define
%         the filters. [Default 'double']
%      options.optimize - The optimization technique used to store the
%         filters. If set to 'none', filters are stored using their full
%         Fourier transform. If 'periodize', filters are periodized to create
%         Fourier transform at lower resolutions. Finally, if 'truncate',
%         the Fourier transform of the filter is truncated and its support is
%         stored. [Default 'truncate']
%
%   The output, a structure, contains the wavelet filters (psi) in a cell
%   array and lowpass filter (phi). Each filter is stored according to the
%   optimization technique specified in options.optimize. In addition, the
%   parameters used to define filters are stored, as well as information on
%   the center and bandwidth of each filter.

function filters = morlet_filter_bank_1d(sig_length,options)
	if nargin < 2
		options = struct();
	end
	
	parameter_fields = {'filter_type','Q','B','J','P','xi_psi','sigma_psi', ...
		'sigma_phi', 'boundary', 'phi_dirac'};
	
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
		'J', floor(log2(sig_length/(options.sigma_psi/sigma0))*options.Q));
	options = fill_struct(options, ...
		'P', round(2^(-1/options.Q)/(1-2^(-1/options.Q))-1/2*options.sigma_phi/(1/2*sigma0/(1-2^(-1/options.Q)))));
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
	for l = 1:length(parameter_fields)
		filters = setfield(filters,parameter_fields{l}, ...
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
	
	filters.N = N;
	
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
