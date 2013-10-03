% WAVELET_FACTORY_2D_PYRAMID : Create wavelet cascade
%
% Usage
%    [Wop, filters] = WAVELET_FACTORY_2D_PYRAMID(filt_opt, scat_opt)
%
% Input
%    filt_opt: The filter options, same as for morlet_filter_bank_2d 
%	 scat_opt: The scattering and wavelet options, same as
%		wavelet_layer_2d / wavelet_2d.
%
% Output
%    Wop: A cell array of wavelet transforms needed for the scattering trans-
%       form.
%    filters: A cell array of the filters used in defining the wavelets.

function [Wop, filters] = wavelet_factory_2d_pyramid(filt_opt, scat_opt)
	
    if(nargin<1)
        filt_opt = struct;
    end
    if(nargin<2)
        scat_opt = struct;
    end

	scat_opt = fill_struct(scat_opt, 'M', 2);
	
	% filters :
	filt_opt = fill_struct(filt_opt, 'type', 'morlet');
	switch (filt_opt.type)
		case 'morlet'
            filt_opt = rmfield(filt_opt, 'type');
			filters = morlet_filter_bank_2d_pyramid(filt_opt);
			
		case 'haar'
            filt_opt = rmfield(filt_opt,'type');
			filters = haar_filter_bank_2d_spatial(filt_opt);
	end
	
	% wavelet transforms :
    wavelet_options = sub_options(scat_opt, {'J', 'precision', 'j_min', 'q_mask', 'all_low_pass'});
	for m = 1:scat_opt.M+1
		Wop{m} = @(x)(wavelet_layer_2d_pyramid(x, filters, wavelet_options));
	end
end
