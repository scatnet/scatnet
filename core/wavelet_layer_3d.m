% WAVELET_LAYER_3D Compute the roto-translation wavelet transform of a scattering layer
%
% Usage
%   [U_Phi, U_Psi] = WAVELET_LAYER_3D(U, filters, filters_rot, options)
%
% Input
%   U (struct): input scattering layer
%   filters (struct): 2d filter bank to apply along spatial variable
%   filters_rot (struct): 1d filter bank to apply along orientation
%   options (struct): same as wavelet_3d
%
% Output
%   U_Phi (struct): low pass convolutions of all signal of layer U
%   U_Psi (struct): high pass convolutions of all signal of layer U
%
% Description
%   This function will compute all the roto-translation wavelet transform
%   of signals contained in the input layer U. If the previous layer
%   is contains only 2d signal, it starts by extracting rotation orbits.
%   It then forward each orbit to WAVELET_3D that will process them
%   independantly.
%
% See also
%   WAVELET_3D, WAVELET_FACTORY_3D

function [U_Phi, U_Psi] = wavelet_layer_3d(U, filters, filters_rot, options)
	
    % do not compute any convolution
    % with psi if the user does get U_psi
	calculate_psi = (nargout>=2); 
	
	% if previous layers contains 2d signal, we must first
	% extract the rotation orbits
	previous_layer_2d = numel(size(U.signal{1})) == 2;
	if (previous_layer_2d)
		Uorb = {};
		p_orb = 1;
		for j = 0:max(U.meta.j)
			orbit = U.meta.j == j;
			y = {U.signal{orbit}};
			y = reshape(cell2mat(y),[size(y{1},1),size(y{1},2),numel(y)]);
			Uorb.signal{p_orb} = y;
			Uorb.meta.j(p_orb) = j;
            all_path_for_orbit = find(orbit);
            Uorb.meta.resolution(p_orb) = U.meta.resolution(end, all_path_for_orbit(1));
			p_orb = p_orb + 1;
		end
		U = Uorb;
	end
	
	% for all signal of U, apply roto-translation wavelet transform
	p2 = 1;
	for p = 1:numel(U.signal)
		y = U.signal{p};
		j = U.meta.j(end,p);
		
		% compute mask for progressive paths
		options.psi_mask = calculate_psi & ...
			(filters.psi.meta.j >= j + filters.meta.Q);
		options.x_resolution = U.meta.resolution(p);
		if (calculate_psi)
			% compute wavelet transform
			[y_Phi, y_Psi, meta_Phi, meta_Psi] = wavelet_3d(y, filters, filters_rot, options);
		else
			y_Phi = wavelet_3d(y, filters, filters_rot, options);
		end
		
		% copy signal and meta for phi
		U_Phi.signal{p} = y_Phi;
		U_Phi.meta.j(:,p) = [U.meta.j(:,p); filters.meta.J];
		if (isfield(U.meta,'theta2'))
			U_Phi.meta.theta2(:,p) = U.meta.theta2(:,p);
		end
		if (isfield(U.meta,'k2'))
			U_Phi.meta.k2(:,p) = U.meta.k2(:,p);
		end
		
		if (calculate_psi)
			% copy signal and meta for psi
			for p_psi = 1:numel(y_Psi)
				U_Psi.signal{p2} = y_Psi{p_psi};
				U_Psi.meta.j(:,p2) = [U.meta.j(:,p);...
					meta_Psi.j2(p_psi)];
				U_Psi.meta.theta2(:,p2) = meta_Psi.theta2(p_psi);
				U_Psi.meta.k2(:,p2) =  meta_Psi.k2(p_psi);
                U_Psi.meta.resolution(p2) = meta_Psi.resolution(p_psi);
				p2 = p2 +1;
			end
		end
		
	end
	
	
	
end

