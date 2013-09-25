% wavelet_factory_2d_spatial: Create wavelet cascade
% Usage
%    [Wop, filters] = wavelet_factory_2d_spatial(filt_opt, scat_opt)
%
% Input
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
	filt_opt = fill_struct(filt_opt, 'type', 'morlet');
	switch (filt_opt.type)
		case 'morlet'	
			filters = morlet_filter_bank_2d_spatial(filt_opt);
			
		case 'haar'
			filters = haar_filter_bank_2d_spatial(filt_opt);
			
	end
	
	% wavelet transforms :
	for m = 1:scat_opt.M+1
		Wop{m} = @(x)(wavelet_layer_2d_pyramid(x, filters, scat_opt));
	end
end
