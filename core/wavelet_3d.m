% wavelet_3d : Compute the wavelet transform of a roto-translation orbit
%
% Usage
%	[x_phi, x_psi] = wavelet_3d(x, filters, filters_rot)
function [y_Phi, y_psi] = wavelet_3d(y, filters, filters_rot, options)
	
	nb_angle = filters_rot.meta.N;
	nb_angle_in = size(y,3);
	y_half_angle = nb_angle_in == nb_angle/2;
	% if only half of the signal is input, the roto-translation
	% convolution can be speeded up by a factor of 2 since
	% \psi_{\theta_2 + \pi} = conj(\psi_{\theta_2})
	% and (PROPERTY_1)
	% |x * \psi_{\theta_1 + \pi}| = |x * \psi_{\theta_1}|
	% we have that
	% | x* \psi_{\theta_1 + \pi} | * \psi_{\theta_2 + \pi}  =
	% conj(| x* \psi_{\theta_1} | * \psi_{\theta_2} )
	
	
	if nargin<3
		options = struc();
	end
	
	v = filters.meta.v;
	
	% option retrieving
	antialiasing = getoptions(options, 'antialiasing', 1);
	psi_mask = getoptions(options, 'psi_mask', ones(1,numel(filters.psi.filter)));
	
	% precomputation
	lastres = log2(filters.meta.size_in(1)/size(y,1));
	margins = filters.meta.margins / 2^lastres;
	
	
	% mirror padding and fft
	yf = zeros(size(y));
	for theta = 1:nb_angle_in
		yf(:,:,theta) = fft2(pad_mirror_2d(y(:,:,theta), margins));
	end
	
	% low pass spatial (filter along first two dimension)
	y_phi = zeros(size(y));
	for theta = 1:nb_angle_in
		y_phi(:,:,theta) = ...
			conv_sub_unpad_2d(yf(:,:,theta), filters.phi);
	end
	
	if (y_half_angle) % recopy thanks to (PROPERTY_1)
		y_phi = cat(3, y_phi, y_phi);
	end
	
	% low pass angle (filter along third dimension)
	% reformat in matrix so that dim 3->1 and 1,2->2
	N = size(y_phi, 1);
	M = size(y_phi, 2);
	y_phi = permute( y_phi, [3, 1 ,2]);
	y_phi = reshape( y_phi, nb_angle, N*M);
	% filter along dim 1
	ds = 2^filters_rot.J;
	y_Phi = conv_sub_1d( y_phi, filters_rot.phi.filter, ds);
	% reformat in original 
	y_Phi = reshape( y_Phi, size(y_Phi,1), N, M);
	y_Phi = permute( y_Phi, [2, 3, 1]);
	
	
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