function [U_Phi, U_Psi] = wavelet_layer_3d(U, filters, filters_rot, options)
	
	
	calculate_psi = (nargout>=2); % do not compute any convolution
	% with psi if the user does get U_psi
	
	
	% if previous layers contains 2d signal, we must first
	% extract the rotation orbits
	previous_layer_2d = numel(size(U.signal{1})) == 2;
	if (previous_layer_2d)
		Uorb = {};
		p_orb = 1;
		for j = 0:max(U.meta.j)
			orbit = U.meta.j == j;
			y = {U.signal{orbit}};
			y = reshape(cell2mat(y),[size(y{1},1),size(y{1},1),numel(y)]);
			Uorb.signal{p_orb} = y;
			Uorb.meta.j(p_orb) = j;
			p_orb = p_orb + 1;
		end
		U = Uorb;
	end
	
	
	p2 = 1;
	for p = 1:numel(U.signal)
		y = U.signal{p};
		j = U.meta.j(end,p);
		
		% compute mask for progressive paths
		options.psi_mask = calculate_psi & ...
			(filters.psi.meta.j >= j + filters.meta.v);
		
		% compute wavelet transform
		[y_Phi, y_Psi] = wavelet_3d(y, filters, filters_rot, options);
		
		% copy signal and meta for phi
		U_Phi.signal{p} = y_Phi.signal{1};
		U_Phi.meta.j(:,p) = [U.meta.j(:,p); y_Phi.meta.J];
		
		
		% copy signal and meta for psi
		for p_psi = 1:numel(y_Psi.signal)
			U_Psi.signal{p2} = y_Psi.signal{p_psi};
			U_Psi.meta.j(:,p2) = [U.meta.j(:,p);...
				y_Psi.meta.j2(p_psi)];
			U_Psi.meta.theta2(:,p2) = y_Psi.meta.theta2(p_psi);
			U_Psi.meta.k2(:,p2) =  y_Psi.meta.k2(p_psi);
			p2 = p2 +1;
		end
		
	end
	
	
	
end

