% cascade_factory_1d: Create wavelet cascade from filters
% Usage
%    cascade = cascade_factory_1d(N, filter_options, scatt_options, M)
% Input
%    N: The size of the signals to be transformed.
%    filter_options: The filter options, same as for filter_bank.
%    scatt_options: General options to be passed to wavelet_1d and 
%        wavelet_layer_1d.
%    M: The maximal order of the scattering transform.
% Output
%    cascade: A cascade structure containing the padding, wavelet and 
%       modulus functions needed for the scattering transform.

function cascade = cascade_factory_1d(N, filter_options, scatt_options, M)
	filters = filter_bank(N,filter_options);
	
	cascade.pad = @(X)(pad_layer_1d(X, 2*N, 'symm'));
	cascade.unpad = @(X)(unpad_layer_1d(X, N));
	
	for m = 0:M
		filt_ind = min(numel(filters), m+1);
		cascade.wavelet{m+1} = @(X)(wavelet_layer_1d(X, ...
			filters{filt_ind}, scatt_options));
		cascade.modulus{m+1} = @modulus_layer;
	end
end