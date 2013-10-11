% FILTER_BANK Create a cell array of filter banks
%
% Usages
%    filters = FILTER_BANK(N)
%
%    filters = FILTER_BANK(N, options)
%
% Input
%    N (int): The size of the input data.
%    options (struct): Filter parameters, see below.
%
% Output
%    filters (struct): A cell array of filter banks corresponding to the
%      data size N and the filter parameters in options.
%
% Description
%    The behavior of the function depends on the value of options.filter_type,
%    which can have the following values:
%       'morlet_1d', 'gabor_1d': Calls MORLET_FILTER_BANK_1D.
%       'spline_1d': Calls SPLINE_FILTER_BANK_1D.
%       'selesnick_1d': Calls SELESNICK_FILTER_BANK_1D.
%    The filter parameters in options are then passed on to these functions.
%    If multiple filter banks are desired, multiple parameters can be supplied
%    by providing a vector of parameter values instead of a scalar (in the 
%    case of filter_type and filter_format, these have to be cell arrays).
%    The function will then split the options structure up into several 
%    parameter sets and call the appropriate filter bank function for each one
%    returning the result as a cell array. If a given field does not have 
%    enough values to specify parameters for all filter banks, the last ele-
%    ment is used to extend the field as needed.
%
%    The specific parameters vary between filter bank types, but the follow-
%    ing are common to all types:
%       options.filter_type: Can be 'morlet_1d', 'gabor_1d', 'spline_1d',
%          or 'selesnick_1d' (default 'morlet_1d').
%       options.boundary: Sets the boundary conditions of the wavelet trans-
%          form. If 'symm', symmetric boundaries will be used, if 'per', per-
%          iodic boundaries will be used (default 'symm').
%       options.precision: Either 'double', or 'single'. Determines the preci-
%          sion of the filters stored and consequently that of the resulting
%          wavelet and scattering transform (default 'double').
%       options.filter_format: Specifies the format in which the filters are 
%          stored. Three formats are available:
%             'fourier': Filters are stored as Fourier transforms defined
%                 over the whole frequency domain of the signal.
%             'fourier_multires': Filters are stored as Fourier transforms 
%                 defined over the frequency domain of the signal at all
%                 resolutions. This requires much more memory, but speeds up
%                 calculations significantly.
%              'fourier_truncated': Stores the Fourier coefficients of each
%                 filter on the support of the filter, reducing memory
%                 consumption and increasing speed of calculations (default).
%
%    For parameters specific to the filter bank type, see the documentation
%    for MORLET_FILTER_BANK_1D, SPLINE_FILTER_BANK_1D, and
%    SELESNICK_FILTER_BANK_1D.
%
% See also
%    WAVELET_FACTORY_1D, WAVELET_FACTORY_2D, WAVELET_1D, WAVELET_2D

function filters = filter_bank(sig_length, options)
	parameter_fields = {'filter_type','Q','B','xi_psi','sigma_psi', ...
		'phi_bw_multiplier','sigma_phi','J','P','spline_order', ...
		'filter_format'};
		
	if nargin < 2
		options = struct();
	end
	
	options = fill_struct(options, 'filter_type', 'morlet_1d');
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
	
	if ~iscell(options.filter_format)
		options.filter_format = {options.filter_format};
	end
		
	bank_count = max(cellfun(@(x)(numel(getfield(options,x))), ...
		parameter_fields)); % number of required filter banks
		
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
        elseif strcmp(options_k.filter_type,'selesnick_1d')
            filters{k} = selesnick_filter_bank_1d(sig_length,options_k);
		else
			error(['Unknown wavelet type ''' options_k.filter_type '''']);
		end
	end
end
