% WAVELET_FACTORY_1D Create wavelet cascade
%
% Usage
%    [Wop, filters] = WAVELET_FACTORY_1D(N, filt_opt, scat_opt)
%
% Input
%    N (int): The size of the signals to be transformed.
%    filt_opt (struct): The filter options, same as FILTER_BANK.
%    scat_opt (struct): The scattering options, same as WAVELET_LAYER_1D.
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
%    provided in filt_opt, the result of which is returned as filters.  Each
%    filter bank is then used to create a layer operator, using the function
%    WAVELET_LAYER_1D. This function takes a layer, a filter bank and a set of
%    parameters as input. WAVELET_FACTORY_1D fixes the filter bank as the
%    element of filters corresponding to the layer order, while scat_opt is
%    used as the parameter struct. The result is a cell array Wop, of layer
%    operators which take one layer as input, and return two layers as output,
%    A and V corresponding to the "average" and "variation" of the input layer.
%
% See also
%    WAVELET_LAYER_1D, WAVELET_1D, FILTER_BANK

function [Wop, filters] = wavelet_factory_1d(N, filt_opt, scat_opt)
	if nargin < 2
		filters = filter_bank(N);
    else
        filters = filter_bank(N, filt_opt);
    end
	
	if nargin < 3
		scat_opt = struct(); 
    end
    scat_opt = fill_struct(scat_opt, 'M', 2); % M is the scattering order
	
    Wop = cell(1,scat_opt.M);
	for m = 0:scat_opt.M
		filt_ind = min(numel(filters), 1+m);
		Wop{1+m} = @(X)(wavelet_layer_1d(X, filters{filt_ind}, scat_opt));
	end
end
