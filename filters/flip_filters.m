% FLIP_FILTERS Reflect filters about origin in frequency.
%
% Usage
%   filters1 = FLIP_FILTERS(filters0)
%
% Input
%   filters0 (struct): The original filter bank, element of output from 
%        FILTER_BANK or related functions.
%
% Output
%   filters1 (struct): The filter bank with each filter reflected around the
%      origin in frequency.
%
% Description
%    Allows to create negative frequency-filters from analytic 
%    (positive-frequency) filters when decomposing complex signals.
%
% See also
%    FILTER_BANK

function filters = flip_filters(filters)
	K = length(filters.psi.filter);
	for k = 1:K
		old_psi = realize_filter(filters.psi.filter{k});
		new_psi = [old_psi(1); old_psi(end:-1:2)];
		opt.filter_format = 'fourier';
		if isstruct(filters.psi.filter{k})
			opt.filter_format = filters.psi.filter{k}.type;
		end
		filters.psi.filter{k} = optimize_filter(new_psi, 0, opt);
	end
end
