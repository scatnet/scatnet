% wavemod_1d_factory: Create wavemod functions from filters
% Usage
%    wavemod = wavemod_1d_factor(N, filter_options, scatt_options, M)
% Input
%    N: The size of the signals to be transformed.
%    filter_options: The filter options, same as for filter_bank.
%    scatt_options: Scattering options to be passed to wavemod_1d.
%    M: The maximal order of the transform.
% Output
%    wavemod: The wavemod functions corresponding to the specified wavelet
%       modulus transform.

function wavemod = wavemod_1d_factory(N,filter_options,scatt_options,M)
	filters = filter_bank(N,filter_options);
	
	for m = 0:M
		filt_ind = min(numel(filters),m+1);
		wavemod{m+1} = @(x)(wavemod_1d(x,filters{filt_ind},scatt_options));
	end
end