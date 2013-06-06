% wavelet_factory_1d: Create wavelet cascade from filters
% Usage
%    [Wop, filters] = wavelet_factory_1d(N, filter_options, scat_options, M)
% Input
%    N: The size of the signals to be transformed.
%    filter_options: The filter options, same as for filter_bank.
%    scat_options: General options to be passed to wavelet_1d and 
%        wavelet_layer_1d.
%    M: The maximal order of the scattering transform.
% Output
%    Wop: A cell array of wavelet transforms needed for the scattering trans-
%       form.
%    filters: A cell array of the filters used in defining the wavelets.

function [Wop, filters] = wavelet_factory_1d(N, filter_options, scat_options, M)
	filters = filter_bank(N, filter_options);
	
	for m = 0:M
		filt_ind = min(numel(filters), m+1);
		scat_options_m = scat_options;
		if m == 0
			scat_options_m.phi_renormalize = 0;
		end
		Wop{m+1} = @(X)(wavelet_layer_1d(X, filters{filt_ind}, scat_options_m));
	end
end