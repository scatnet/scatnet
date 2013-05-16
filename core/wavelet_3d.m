% wavelet_3d : Compute the wavelet transform of a roto-translation orbit
%
% Usage
%	[y_Phi, y_Psi] = wavelet_3d(y, filters, filters_rot, options)
%		compute the roto-translation convolution of a three dimensional
%		signal y, with roto-translation wavelets Psi defined
%		as the separable product
%		Psi(u,v,theta) = psi(u,v) *
%
% Ref
%	Rotation, Scaling and Deformation Invariant Scattering for Texture
%	Discrimination, Laurent Sifre, Stephane Mallat
%	Proc of CVPR 2013
%	http://www.cmapx.polytechnique.fr/~sifre/research/cvpr_13_sifre_mallat_final.pdf

function [y_Phi, y_Psi] = wavelet_3d(y, filters, filters_rot, options)
	if (nargin<4)
		options = struct();
	end
	
	nb_angle = filters_rot.N;
	L = nb_angle/2;
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
	J = filters.meta.J;
	
	% option retrieving
	antialiasing = getoptions(options, 'antialiasing', 1);
	antialiasing_rot = getoptions(options, 'antialiasing_rot', -1);
	psi_mask = getoptions(options, 'psi_mask', ones(1,numel(filters.psi.filter)));
	
	% precomputation
	lastres = log2(filters.meta.size_in(1)/size(y,1));
	
	% mirror padding and fft
	margins = filters.meta.margins / 2^lastres;
	for theta = 1:nb_angle_in
		tmp = fft2(pad_mirror_2d(y(:,:,theta), margins));
		if (theta==1) % prealocate when we know the size
			yf = zeros([size(tmp), nb_angle_in]);
		end
		yf(:,:,theta) = tmp;
	end
	
	% ------- LOW PASS -------
	
	% low pass spatial (filter along first two dimension)
	for theta = 1:nb_angle_in
		ds = max(floor(J/v)- lastres - antialiasing, 0);
		margins = filters.meta.margins / 2^(lastres+ds);
		tmp = ...
			conv_sub_unpad_2d(yf(:,:,theta), filters.phi.filter, ds, margins);
		if (theta == 1) % prealocate when we know the size
			y_phi = zeros([size(tmp), nb_angle_in]);
		end
		y_phi(:,:,theta) = tmp;
	end
	
	if (y_half_angle) % recopy thanks to (PROPERTY_1)
		y_phi = cat(3, y_phi, y_phi);
	end
	% fourier angle
	y_phi_f = fft(y_phi, [], 3);
	
	
	% low pass angle to obtain
	% ------- PHI(U,V) * PHI(THETA) -------
	phi_angle = filters_rot.phi.filter;
	ds = max(filters_rot.J/filters_rot.Q - antialiasing_rot, 0);
	y_Phi.signal{1} = real(...
		sub_conv_1d_along_third_dim_simple(y_phi_f, phi_angle, ds));
	y_Phi.meta.J(1) = ...
		filters.phi.meta.J;
	
	
	
	% ------- HIGH PASS -------
	p = 1;
	
	% high pass angle to obtain
	% ------- PHI(U,V) * PSI(THETA) -------
	for k2 = 0:numel(filters_rot.psi.filter)-1
		psi_angle = filters_rot.psi.filter{k2+1};
		y_Psi.signal{p} = ...
			sub_conv_1d_along_third_dim_simple(y_phi_f, psi_angle, 0);
		y_Psi.meta.theta2(p) = 0;
		y_Psi.meta.j2(p) = filters.phi.meta.J;
		y_Psi.meta.k2(p) = k2;
		p = p + 1;
	end
	
	
	for lambda2 = find(psi_mask)
		theta2 = filters.psi.meta.theta(lambda2);
		j2 = filters.psi.meta.j(lambda2);
		ds = max(floor(j2/v)- lastres - antialiasing, 0);
		
		% convolution with psi_{j1, theta + theta2}
		for theta = 1:nb_angle_in
			theta_sum_mod2L =  1 + mod(theta + theta2 - 2, 2*L);
			theta_sum_modL =  1 + mod(theta + theta2 - 2, L);
			lambda2p1 = find(filters.psi.meta.theta == theta_sum_modL & ...
				filters.psi.meta.j == j2);
			psi = filters.psi.filter{lambda2p1};
			margins = filters.meta.margins / 2^(lastres+ds);
			tmp = ...
				conv_sub_unpad_2d(yf(:,:,theta), psi, ds, margins);
			
			if (theta == 1) % prealocate when we know the size
				y_psi = zeros([size(tmp), nb_angle_in]);
			end
			
			% use PROPERTY_1 to compute convolution with filters that
			% have an angle > pi
			if (theta_sum_mod2L <= L)
				y_psi(:,:, theta)  = tmp;
			else
				y_psi(:,:, theta) = conj(tmp);
			end
		end
		
		if (y_half_angle) % thanks to PROPERTY_1
			y_psi = cat(3, y_psi, conj(y_psi));
		end
		
		% fourier angle
		y_psi_f = fft(y_psi,[],3);
		
		% low pass angle to obtain
		% ------- PSI(U,V) * PHI(THETA) -------
		phi_angle = filters_rot.phi.filter;
		y_Psi.signal{p} = ...
			sub_conv_1d_along_third_dim_simple(y_psi_f, phi_angle, 0);
		y_Psi.meta.j2(p) = filters.phi.meta.J;
		y_Psi.meta.theta2(p) = -1;
		y_Psi.meta.k2(p) = -1;
		p = p+1;
		
		% high pass angle to obtain
		% ------- PSI(U,V) * PSI(THETA) -------
		for k2 = 0:numel(filters_rot.psi.filter)-1
			psi_angle = filters_rot.psi.filter{k2+1};
			y_Psi.signal{p} = ...
				sub_conv_1d_along_third_dim_simple(y_psi_f, psi_angle, 0);
			y_Psi.meta.theta2(p) = theta2;
			y_Psi.meta.j2(p) = j2;
			y_Psi.meta.k2(p) = k2;
			p = p + 1;
		end
	end
end


function z_conv_filter = sub_conv_1d_along_third_dim_simple(zf, filter, ds)
	filter_rs = repmat(reshape(filter.coefft{1},[1,1,numel(filter.coefft{1})]),...
		[size(zf,1),size(zf,2),1]);
	z_conv_filter = ifft(zf.* filter_rs,[],3);
	if (ds>0) % optimization
		z_conv_filter = z_conv_filter(:,:,1:2^ds:end);
	end
end


% slower than sub_conv_1d_along_third_dim_simple because of reshape and
% sum overhead
% function z_conv_filter = sub_conv_1d_along_third_dim(zf, filter, ds)
% 	N = size(zf, 1);
% 	M = size(zf, 2);
% 	nb_angle = size(zf, 3);
% 	% reformat z to be compatible with conv_sub_1d
% 	% where filtering is along dimension 1
% 	zf = permute( zf, [3, 1 ,2]);
% 	zf = reshape( zf, nb_angle, N*M);
%
% 	z_conv_filter = conv_sub_1d( zf, filter, ds);
% 	nb_angle_ds = size(z_conv_filter, 1);
% 	% reformat in original format
% 	z_conv_filter = reshape( z_conv_filter, nb_angle_ds, N, M);
% 	z_conv_filter = permute( z_conv_filter, [2, 3, 1]);
% end




