function [U_phi, U_psi] = wavelet_layer_2d_pyramid(U, filters, options)
	
	calculate_psi = (nargout>=2); % do not compute any convolution
	% with psi if the user does not get U_psi
	all_low_pass = getoptions(options, 'all_low_pass',0);
	
	if ~isfield(U.meta,'theta')
		U.meta.theta = zeros(0,size(U.meta.j,2));
	end
	J = getoptions(options, 'J', 4);
	Q = filters.meta.Q;
	
	w_options = options;
	p2 = 1;
	for p = 1:numel(U.signal)
		x = U.signal{p};
		if (numel(U.meta.j)>0)
			j = U.meta.j(end,p);
			w_options.j_min = 1;
		else
			j = 0;
			w_options.j_min = 0;
		end
		
		% compute mask for progressive paths
		w_options.J = J-j;
		if (numel(U.meta.q) > 0)
			w_options.q_mask = zeros(1,Q);
			w_options.q_mask(U.meta.q(end, p) +1) = 1;
		end
		
		if (calculate_psi)
			% compute wavelet transform
			[x_phi, x_psi] = wavelet_2d_pyramid(x, filters, w_options);
			
			% copy signal and meta for phi
			U_phi.signal{p} = x_phi.signal{1};
			U_phi.meta.j(:,p) = [U.meta.j(:,p); J];
			U_phi.meta.q(:,p) = U.meta.q(:,p);
			U_phi.meta.theta(:,p) = U.meta.theta(:,p);
			if (all_low_pass == 1)
				U_phi.all_low_pass{p} = x_phi.all_low_pass;
			end
			
			
			% copy signal and meta for psi
			for p_psi = 1:numel(x_psi.signal)
				U_psi.signal{p2} = x_psi.signal{p_psi};
				U_psi.meta.j(:,p2) = [U.meta.j(:,p);...
					j+ x_psi.meta.j(p_psi)];
				U_psi.meta.theta(:,p2) = [U.meta.theta(:,p);...
					x_psi.meta.theta(p_psi)];
				U_psi.meta.q(:,p2) = [U.meta.q(:,p);...
					x_psi.meta.q(p_psi)];
				p2 = p2 +1;
			end
			
		else
			% compute only low pass
			x_phi = wavelet_2d_pyramid(x, filters, w_options);
			
			% copy signal and meta for phi
			U_phi.signal{p} = x_phi.signal{1};
			U_phi.meta.j(:,p) = [U.meta.j(:,p); J];
			U_phi.meta.theta(:,p) = U.meta.theta(:,p);
			U_phi.meta.q(:,p) = U.meta.q(:,p);
			
		end
		
	end
	
end
