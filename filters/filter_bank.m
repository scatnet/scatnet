%TODO update doc
%FILTER_BANK Creates a filter bank
%   filters = filter_bank(sig_length,options) generates a filter bank for 
%   signals of length sig_length using the options specified in options.
%   
%   The following options can be specified:
%      options.wavelet_type - The type of wavelet filter to create. Can be
%         either 'morlet', 'gabor', or 'spline', for a Morlet filter bank,
%         a Gabor filter bank or a wavelet spline filter bank, respectively. 
%         Since the Morlet and spline filter banks have a vanishing moment, 
%         they are highly recommended. For audio signals, however, energy at 
%         very low frequencies is often small, so Gabor filters can be used 
%         in the first-order filter bank. [Default 'morlet']
%      options.boundary - The boundary conditions for filter convolutions. Can
%         be 'symm' or 'per', corresponding to symmetric and periodic
%         boundary conditions, respectively. For 'symm', the filters will be
%         created to cover twice the length of the signal. [Default 'symm']
%      options.Q - Parameter for the Morlet filter bank. Specifies the 
%         number of wavelets per octave at critical sampling in frequency. 
%         Q = 1 gives the traditional dyadic wavelet filter bank. [Default 1]
%      options.a - Parameter for the Morlet filter bank. Specifies the 
%         dilation factor between adjacent wavelets. The factor
%         2^(1/Q) corresponds to critical sampling. More redundant frequency
%         sampling can be obtained by decreasing a. [Default 2^(1/Q)]
%      options.J - Parameter for the Morlet filter bank. Specifies the number 
%         of logarithmically spaced wavelets. This controls the minimum 
%         frequency bandwidth of the wavelets and consequently the maximum 
%         temporal bandwidth. For a filter bank with parameters Q, a, J, the 
%         maximum temporal bandwidth is Q*a^J.
%         [Default log(sig_length/Q)/log(a)]
%      options.gabor - Parameter for the Morlet filter bank. If 0, Morlet
%         wavelets are used, whereas if 1, Gabor filters are used. Since the 
%         former have a vanishing moment, they are highly recommended. For 
%         audio signals, however, energy at very low frequencies is often 
%         small, so Gabor filters can be used in the first-order filter bank.
%         [Default 0]
%      options.spline_order - Parameter for the spline filter bank. Specifies
%         the order of the spline wavelets. Allowed values are 1 (for linear
%         splines) and 3 (for cubic splines). [Default 3]
%
%   To create multiple filter banks, it suffices to specify a vector of values
%   instead of a scalar for any of the above parameters. The output will then
%   consist of a structure array where the k:th filter bank is defined by
%   the k:th (or last) element of each parameter vector. These multiple filter
%   banks can then be used to calculate scattering coefficients with differing
%   filters for different orders. For example, we can define
%
%      filt_opt.wavelet_type = {'gabor','morlet'};
%      filt_opt.Q = [8 1];
%      filt_opt.J = T_to_J(8192,filt_opt.Q);
%      filters = filter_bank(65536,filt_opt);
%
%    Now filters{1} contains a Gabor filter bank with Q=8 and filters{2}
%    contains a Morlet fitler bank with Q=1, both with a lowpass filter
%    of duration 8192 samples. Both filter banks are defined for signals of
%    length 65536.


function filters = filter_bank(sig_length,options)
	parameter_fields = {'filter_type','Q','B','xi_psi','sigma_psi', ...
		'phi_bw_multiplier','sigma_phi','J','P','spline_order', ...
		'precision','filter_format'};
	
	options = fill_struct(options, 'filter_type', 'morlet');
	options = fill_struct(options, 'Q', []);
	options = fill_struct(options, 'B', []);
	options = fill_struct(options, 'xi_psi', []);
	options = fill_struct(options, 'sigma_psi', []);
	options = fill_struct(options, 'phi_bw_multiplier', []);
	options = fill_struct(options, 'sigma_phi', []);
	options = fill_struct(options, 'J', []);
	options = fill_struct(options, 'P', []);
	options = fill_struct(options, 'spline_order', []);
	options = fill_struct(options, 'precision', 'double');
	options = fill_struct(options, 'filter_format', 'fourier_truncated');
	
	if ~iscell(options.filter_type)
		options.filter_type = {options.filter_type};
	end
	
	if ~iscell(options.precision)
		options.precision = {options.precision};
	end
	
	if ~iscell(options.filter_format)
		options.filter_format = {options.filter_format};
	end
		
	bank_count = max(cellfun(@(x)(numel(getfield(options,x))), ...
		parameter_fields));
		
	for k = 1:bank_count
		% Extract the k:th element from each parameter field
		options_k = options;
		for l = 1:length(parameter_fields)
			if ~isfield(options_k,parameter_fields{l}) || ...
				isempty(getfield(options_k,parameter_fields{l}))
				continue;
			end
			value = getfield(options_k,parameter_fields{l});
			if isnumeric(value)
				value_k = value(min(k,numel(value)));
			elseif iscell(value)
				value_k = value{min(k,numel(value))};
			else
				value_k = [];
			end
			options_k = setfield(options_k,parameter_fields{l}, ...
				value_k);
		end
		
		% Calculate the k:th filter bank
		if strcmp(options_k.filter_type,'morlet_1d') || ...
		   strcmp(options_k.filter_type,'gabor_1d')
			filters{k} = morlet_filter_bank_1d(sig_length,options_k);
		elseif strcmp(options_k.filter_type,'spline_1d')
			filters{k} = spline_filter_bank_1d(sig_length,options_k);
		else
			error(['Unknown wavelet type ''' options_k.filter_type '''']);
		end
	end
end
