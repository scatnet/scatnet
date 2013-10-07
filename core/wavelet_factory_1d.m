% WAVELET_FACTORY_1D Create wavelet cascade
%
% Usage
%    [Wop, filters] = WAVELET_FACTORY_1D(N, filter_options, scat_options)
%
% Input
%    N (int): The size of the signals to be transformed.
%    filter_options (struct): The filter options, same as for filter_bank.
%    scat_options (struct): Parameters for creating cascade and to be passed
%        to WAVELET_LAYER_1D and WAVELET_1D. Cascade parameters are:
%           M (int): The maximal order of the scattering transform (default 
%              2).
%
% Output
%    Wop (cell): A cell array of wavelet layer transforms needed for the  
%       scattering transform.
%    filters (cell): A cell array of the filters used in defining the 
%       wavelets.
%
% Description
%    In order to calculate the scattering coefficients of a signal, a set of 
%    filter banks need to be defined first. Given these filter banks, wavelet
%    transforms can be defined on scattering layers. To obtain the former,
%    WAVELET_FACTORY_1D calls the FILTER_BANK function using the parameters
%    provided in filter_options, the result of which is returned as filters.
%    Each filter bank is then used to create a layer operator, using the 
%    function WAVELET_LAYER_1D. This function takes a layer, a filter bank
%    and a set of parameters as input. WAVELET_FACTORY_1D fixes the filter 
%    bank as to the element of filters corresponding to the layer order, while
%    scat_options is used as the parameters. The result is a cell array Wop,
%    of layer operators which take one layer as input, and return two layers
%    as output, A and V corresponding to the "average" and "variation" of the
%    input layer.
%
% See also
%    WAVELET_LAYER_1D, WAVELET_1D, FILTER_BANK

function [Wop, filters] = wavelet_factory_1d(N, filter_options, scat_options)
	if nargin < 2
		filter_options = struct();
	end
	
	if nargin < 3
		scat_options = struct();
	end
	
	scat_options = fill_struct(scat_options, 'M', 2);
	
	filters = filter_bank(N, filter_options);
	
	for m = 0:scat_options.M
		filt_ind = min(numel(filters), m+1);
		Wop{m+1} = @(X)(wavelet_layer_1d(X, filters{filt_ind}, scat_options));
	end
end