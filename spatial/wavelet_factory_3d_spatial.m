function [Wop, filters, filters_rot] = wavelet_factory_3d_spatial(filt_opt, filt_rot_opt, scat_opt)
	%WAVELET_FACTORY_3D_SPATIAL Summary of this function goes here
	%   Detailed explanation goes here
	
	filt_opt.null = 1;
	scat_opt.null = 1;
	scat_opt = fill_struct(scat_opt, 'M', 2);
	
	% filters :
	filters = morlet_filter_bank_2d_spatial(filt_opt);
	
	
end

