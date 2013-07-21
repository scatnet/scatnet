% wavelet_factory_2d: Create wavelet cascade from filters
% Usage
%    [Wop, filters] = wavelet_factory_2d(size_in, filt_opt, scat_opt, M)
%
% Input
%    size_in: The size of the signals to be transformed.
%    filt_opt: The filter options, same as for morlet_filter_bank_2d 
%	 scat_opt: The scattering and wavelet options, same as
%		wavelet_layer_1d/wavelet_1d.
%
% Output
%    Wop: A cell array of wavelet transforms needed for the scattering trans-
%       form.
%    filters: A cell array of the filters used in defining the wavelets.

function [Wop, filters] = wavelet_factory_2d_spatial(filt_opt, scat_opt)
	
	filt_opt.null = 1;
	scat_opt.null = 1;
	scat_opt = fill_struct(scat_opt, 'M', 2);
	
	% filters :
	filters = morlet_filter_bank_2d_spatial(filt_opt);
	
	% wavelet transforms :
	for m = 1:scat_opt.M+1
		Wop{m} = @(x)(wavelet_layer_2d_spatial(x, filters, scat_opt));
	end
end