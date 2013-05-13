% wavelet_3d : Compute the wavelet transform of a roto-translation orbit
%
% Usage
%	[x_phi, x_psi] = wavelet_3d(x, filters, filters_rot)
function [y_phi, y_psi] = wavelet_3d(y, filters, filters_rot, options)
	
	nb_angle = filters.meta.filters_rot.N;
	
	
	
	
	if nargin<3
		options = struc();
	end
	
	v = filters.meta.v;
	
	% option retrieving
	antialiasing = getoptions(options, 'antialiasing', 1);
	psi_mask = getoptions(options, 'psi_mask', ones(1,numel(filters.psi.filter)));
	
	
	% precomputation
	lastres = log2(filters.meta.size_in(1)/size(x,1));
	margins = filters.meta.margins / 2^lastres;
	% mirror padding and fft
	for theta = 1:step_angle:nb_angle
		xf(:,:,theta) = fft2(pad_mirror_2d(x(:,:,theta), margins));
	end
	
	% low pass filter Phi Phi
	% low pass spatial
	for theta = 1:step_angle:nb_angle
		xf2d = xf(:,:,theta);
		filter = filters.phi;
		ds = max(floor(J/v)- lastres - antialiasing, 0);
		x_conv_phi(:,:,theta) = conv_sub_unpad_2d(xf(:,:,theta));
	end
	% low pass angle
	phi_rot = repmat(
	x_conv_Phi = ifft(x_conv_phi .* repm
	
	
end