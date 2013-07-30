function [U_Phi, U_Psi] = wavelet_layer_3d_spatial(U, filters, filters_rot, options)
	
	calculate_psi = (nargout>=2); % do not compute any convolution
	% with psi if the user does not get U_psi
	%%
	J = getoptions(options, 'J', 4);
	w_options = options;
	L = filters.meta.L;
	%%
	% if previous layer is output of 2d wavelet transform,
	% extract the orbits
	if (size(U.meta.j,1) == 1)
		for j = 0:max(U.meta.j)
			for theta = 1:L
				p = find(U.meta.j(1,:) == j &...
					U.meta.theta(1,:) == theta);
				if (theta == 1)
					tmp = zeros([size(U.signal{p}), L]);
				end
				tmp(:, :, theta) = U.signal{p};
			end
			U_orb.signal{j+1} = tmp;
			U_orb.meta.j(j+1) = j;
		end
	else
		U_orb = U;
	end
	
	%% for each orbit, apply the 3d wavelet tranform
	
	next_p_phi = 1;
	U_phi_meta = struct();
	U_psi_meta = struct();
	for p = 1:numel(U_orb.signal)
		if (calculate_psi)
			[y_Phi, y_Psi] = wavelet_3d_spatial(U_orb.signal{p});
			if (p == 1)
				[phifn, phinfn1, phinfn2] = merge_fieldnames(U_orb.meta, y_Phi.meta);
				[psifn, psinfn1, psinfn2] = merge_fieldnames(U_orb.meta, y_Psi.meta);
			end
		else
			y_Phi = wavelet_3d_spatial(U_orb.signal{p});
		end
		% copy the paths
		U_Phi.signal{p} = y_Phi.signal;
		%U_Phi.meta.j(:,p) = [U_orb.meta.j(:,p); J];
		%U_Phi.meta.theta2(:,p) = U_Phi.
		for p2 = 1:numel(y_Phi.signal)
			U_Phi.signal{next_p_phi} = y_Phi.signal{p2};
			U_phi_meta = extend_meta(next_p_phi,...
				U_phi_meta,...
				U_orb.meta,...
				p,...
				y_Phi.meta,...
				p2,...
				phifn,...
				phinfn1,...
				phinfn2);
		end
		if (calculate_psi)
			for p2 = 1:numel(y_Psi.signal)
				
				
			end
		end
	end
	
end