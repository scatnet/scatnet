function [U_phi, U_psi] = wavelet_layer_2d_spatial(U, filters, options)
	
	calculate_psi = (nargout>=2); % do not compute any convolution
	% with psi if the user does get U_psi
	
	if ~isfield(U.meta,'theta')
		U.meta.theta = zeros(0,size(U.meta.j,2));
	end
	J = getoptions(options, 'J', 4);
	
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
		
		if (calculate_psi)
			% compute wavelet transform
			[x_phi, x_psi] = wavelet_2d_spatial(x, filters, w_options);
			
			% copy signal and meta for phi
			U_phi.signal{p} = x_phi.signal{1};
			U_phi.meta.j(:,p) = [U.meta.j(:,p); J];
			U_phi.meta.theta(:,p) = U.meta.theta(:,p);
			
			% copy signal and meta for psi
			for p_psi = 1:numel(x_psi.signal)
				U_psi.signal{p2} = x_psi.signal{p_psi};
				U_psi.meta.j(:,p2) = [U.meta.j(:,p);...
					j+ x_psi.meta.j(p_psi)];
				U_psi.meta.theta(:,p2) = [U.meta.theta(:,p);...
					x_psi.meta.theta(p_psi)];
				p2 = p2 +1;
			end
			
		else
			% compute only low pass
			x_phi = wavelet_2d_spatial(x, filters, w_options);
			
			% copy signal and meta for phi
			U_phi.signal{p} = x_phi.signal{1};
			U_phi.meta.j(:,p) = [U.meta.j(:,p); J];
			U_phi.meta.theta(:,p) = U.meta.theta(:,p);
			
		end
		
	end
	
end
