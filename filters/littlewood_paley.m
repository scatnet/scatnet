% LITTLEWOOD_PALEY Calculate Littlewood-Paley sum of a filter bank
%
% Usage
%    A = littlewood_paley(filters, N);
%
% Input
%    filters (struct): filter bank (see FILTER_BANK)
%    N (vector, optional): the signal size at which the sum should be 
%        calculated
%
% Description
%    The function computes the Littlewood-Paley sum of the filter bank at the
%    signal size N, which needs to be of the form filters.meta.size_filter*2^(-j0), where 
%    filters.N is the size for which the filters are defined.
% See also
%   PLOT_LITTLEWOOD_PALEY_1D, DISPLAY_LITTLEWOOD_PALEY_2D, FILTER_BANK

function energy = littlewood_paley(filters,N)
	if nargin < 2
		N = [];	
	end
	
	if isempty(N) && isfield(filters,'meta') && isfield(filters.meta,'size_filter')
		N = filters.meta.size_filter;
	else
		error('Unable to find max filter size!');
	end
	
	if length(N) == 1
		N = [N 1];
	end

	energy = zeros(N);
	for p = 1:numel(filters.psi.filter)
		filter_coefft = realize_filter(filters.psi.filter{p},N);
		energy = energy + abs(filter_coefft.^2);
	end

	energy = 0.5*(energy + circshift(rot90(energy,2), [1, 1]));

	filter_coefft = realize_filter(filters.phi.filter,N);
	energy = energy + abs(filter_coefft.^2);
end
