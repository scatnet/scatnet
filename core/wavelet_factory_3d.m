function [ Wop, filters, filters_rot ] = ...
		wavelet_factory_3d(size_in, filt_opt, filt_rot_opt, scat_opt)
	
	filt_opt.null = 1;
	filt_rot_opt.null = 1;
	scat_opt.null = 1;
	
	% filters along spatial variable
	filters = morlet_filter_bank_2d(size_in, filt_opt);
	
	% filters along angular variable
	sz = filters.meta.L * 2; % L orientations between 0 and pi
	% periodic convolutions along angles
	filt_rot_opt.boundary = 'per';
	filt_rot_opt.filter_format = 'fourier_multires';
	filt_rot_opt.J = 3;
	filt_rot_opt.P = 0;
	filters_rot = morlet_filter_bank_1d(sz, filt_rot_opt);
	
	% number of layer
	scat_opt = fill_struct(scat_opt, 'M', 2);
	
	% first wavelet transform is an usual wavelet transform
	Wop{1} = @(x)(wavelet_layer_2d(x, filters, scat_opt));
	
	% other wavelet transform are roto-translation wavelet
	for m = 2:scat_opt.M+1
		Wop{m} = @(x)(wavelet_layer_3d(x, filters, filters_rot, scat_opt));
	end
end

