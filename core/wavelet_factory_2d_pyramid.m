% WAVELET_FACTORY_2D_PYRAMID Create 2d wavelet cascade
%
% Usage
%    [Wop, filters] = WAVELET_FACTORY_2D_PYRAMID(filt_opt, scat_opt)
%
% Input
%    filt_opt (struct): the filter options, same as for MORLET_FILTER_BANK_2D_PYRAMID 
%	 scat_opt (Struct): the scattering and wavelet options, same as WAVELET_2D_PYRAMID
%       with an additonal optional field 
%           M (int) : the number of layer of the scattering transform
%
% Output
%    Wop (cell of function_handle): contains the wavelet transforms to
%       apply during scattering computation
%    filters (struct): a 2d filter bank
%
% Description
%
% See also
%   SCAT, WAVELET_2D_PYRAMID, WAVELET_LAYER_2D_PYRAMID


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
	end
	
	% wavelet transforms :
    wavelet_options = sub_options(scat_opt, {'J', 'precision', 'j_min', 'q_mask', 'all_low_pass'});
	for m = 1:scat_opt.M+1
		Wop{m} = @(x)(wavelet_layer_2d_pyramid(x, filters, wavelet_options));
	end
end
