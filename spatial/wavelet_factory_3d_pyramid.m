function [Wop, filters, filters_rot] = wavelet_factory_3d_pyramid(filt_opt, filt_rot_opt, scat_opt)
	
	filt_opt.null = 1;
	scat_opt.null = 1;
	scat_opt = fill_struct(scat_opt, 'M', 2);
	
	precision = getoptions(scat_opt, 'precision', 'single');
	% filters :
	filters = morlet_filter_bank_2d_pyramid(filt_opt);
	
	% filters along angular variable
	sz = filters.meta.L * 2; % L orientations between 0 and pi
	% periodic convolutions along angles
	filt_rot_opt.boundary = 'per';
	filt_rot_opt.filter_format = 'fourier_multires';
	filt_rot_opt.J = 3;
	filt_rot_opt.P = 0;
	filt_rot_opt.Q = 1;
	filters_rot = morlet_filter_bank_1d(sz, filt_rot_opt);
	if strcmp(precision,'single')
		filters_rot = singlify_filter_bank(filters_rot);
	end
	
	% first layer : usual 2d wavelet transform
	Wop{1} = @(x)(wavelet_layer_2d_pyramid(x, filters, scat_opt));
	Wop{2} = @(x)(wavelet_layer_3d_spatial(x, filters, filters_rot, scat_opt));
	Wop{3} = @(x)(wavelet_layer_3d_spatial(x, filters, filters_rot, scat_opt));
	
end

