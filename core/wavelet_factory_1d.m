% wavelet_factory_1d: Create wavelet cascade from filters
% Usage
%    [W, filters] = wavelet_factory_1d(N, filter_options, scat_options, M)
% Input
%    N: The size of the signals to be transformed.
%    filter_options: The filter options, same as for filter_bank.
%    scat_options: General options to be passed to wavelet_1d and 
%        wavelet_layer_1d.
%    M: The maximal order of the scattering transform.
% Output
%    W: A cell array of wavelet transforms needed for the scattering trans-
%       form.
%    filters: A cell array of the filters used in defining the wavelets.

function [W, filters] = wavelet_factory_1d(N, filter_options, scat_options, M)
	filters = filter_bank(N, filter_options);
	
	for m = 0:M
		filt_ind = min(numel(filters), m+1);
		W{m+1} = @(X)(wavelet_layer_1d(X, filters{filt_ind}, scat_options));
	end
end