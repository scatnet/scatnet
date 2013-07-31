function [U_Phi, U_Psi] = wavelet_layer_3d_spatial(...
		U, filters, filters_rot, options)
	
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
	
	p2 = 1;
	if (calculate_psi) % first application
		
		for p = 1:numel(U_orb.signal)
			j = U_orb.meta.j(end, p);
			
			% configure wavelet transform
			w_options.angular_range = 'zero_pi';
			w_options.j_min         = 1;
			w_options.J             = J - j;
			
			% compute wavelet transform
			[y_Phi, y_Psi] = wavelet_3d_spatial(U_orb.signal{p},...
				filters, filters_rot, w_options);
			
			% copy signal and meta
			U_Phi.signal{p} = y_Phi.signal{1};
			U_Phi.meta.j(:,p) = [U_orb.meta.j(:,p), J];
			
			for p_psi = 1:numel(y_Psi.signal)
				U_Psi.signal{p2} = y_Psi.signal{p_psi};
				
				U_Psi.meta.j(:,p2)     = j;
				U_Psi.meta.j2(:,p2)    = y_Psi.meta.j2(:,p_psi) + j;
				U_Psi.meta.theta(:,p2) = y_Psi.meta.theta2(:,p_psi);
				U_Psi.meta.k(:,p2)     = y_Psi.meta.k2(:,p_psi);
				
				p2 = p2 + 1;
			end
		end
	else  % second application, only compute low pass
		for p = 1:numel(U_orb.signal)
			
			% configure wavelet transform
			w_options.angular_range = 'zero_2pi';
			
			% compute wavelet transform (low pass only)
			y_Phi = wavelet_3d_spatial(U_orb.signal{p},...
				filters, filters_rot, w_options);
			
			%
			U_Phi.signal{p} = y_Phi.signal{1};
			
			
		end
		U_Phi.meta = U_orb.meta;
		U_Phi.meta.j = [U_Phi.meta.j; J*ones(1, size(U_Phi.meta.j,2))];
	end
	
end