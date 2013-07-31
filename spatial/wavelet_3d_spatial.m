function [y_Phi, y_Psi] = wavelet_3d_spatial(y,...
		filters, filters_rot, options)
	%%
	angular_range = options.angular_range;
	precision = getoptions(options, 'precision', 'single');
	oversampling_rot = getoptions(options, 'oversampling_rot', -1);
	j_min = getoptions(options, 'j_min', 0);
	calculate_psi = (nargout>=2); % do not compute any convolution
	J = options.J;
	L = filters_rot.N / 2;
	[N, M, T] = size(y);
	
	% find out the resolution
	switch (angular_range)
		case 'zero_pi'
			angular_res = floor(log2(2*L/(2*T)));
		case 'zero_2pi'
			angular_res = floor(log2(2*L/T));
		otherwise
			error('unspecified angular range');
	end
	
	
	
	%%%%%%%%%%%%%%%%%%
	%%% low passes %%%
	%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%
	%%% phi - phi %%%%
	%%%%%%%%%%%%%%%%%%
	
	%% low pass filter spatial : cascade with h for every slice
	% initialize structure
	if strcmp(precision, 'single')
		hy.signal{1} = single(y);
	else
		hy.signal{1} = y;
	end
	hy.meta.j(1) = 0;
	
	% low pass spatial using a pyramid
	h = filters.h.filter;
	for j = 1:J
		for theta = 1:T % filter each slice
			if (theta == 1) % allocate when size is known
				tmp_slice = ...
					convsub2d_spatial(hy.signal{j}(:,:,theta), h, 1);
				tmp = zeros([size(tmp_slice), T]);
				tmp(:,:,theta) = tmp_slice;
			else
				clear tmp_slice;
				tmp(:,:,theta) = ...
					convsub2d_spatial(hy.signal{j}(:,:,theta), h, 1);
			end
		end
		hy.signal{j+1} = tmp;
		hy.meta.j(j+1) = j;
	end
	y_phi.signal{1} = hy.signal{J+1};
	y_phi.meta.j(1) = hy.meta.j(J+1);
	
	%% low pass filter anguler : fft along anguler
	% initialize structure (recopy if range is zero_pi)
	ds = max(filters_rot.J/filters_rot.Q - oversampling_rot, 0);
	if (2^ds == 2*L)
		% in this case it is faster to compute the sum along the angle
		y_Phi.signal{1} = sum(y_phi.signal{1},3) / 2^(ds/2);
	else
		if (strcmp(angular_range, 'zero_pi'))
			% divide by sqrt(2) for energy preservation
			y_phi.signal{1} = repmat(y_phi.signal{1}, [1 1 2]) / sqrt(2);
		end
		y_phi_f = fft(y_phi.signal{1}, [], 3);
		phi_angle = filters_rot.phi.filter;
		y_Phi.signal{1} = real(...
			sub_conv_1d_along_third_dim_simple(y_phi_f, phi_angle, ds));
	end
	y_Phi.meta.J = J;
	y_Phi.meta.J_theta = filters_rot.J;
	
	
	%%
	
	%%%%%%%%%%%%%%%%%%%
	%%% high passes %%%
	%%%%%%%%%%%%%%%%%%%
	
	if (calculate_psi)
		p = 1;
		%%%%%%%%%%%%%%%%%%
		%%% phi - psi %%%%
		%%%%%%%%%%%%%%%%%%
		
		%% low pass spatial - already computed
		%% high pass angular
		% NOTE : y_phi_f
		% (the (angular) fourier transform of y * (spatial) phi)
		% might have already been computed
		if ~exist('y_phi_f', 'var')
			% fourier angle
			if (strcmp(angular_range, 'zero_pi'))
				% divide by sqrt(2) for energy preservation
				y_phi.signal{1} = repmat(y_phi.signal{1}, [1 1 2]) / sqrt(2);
			end
			y_phi_f = fft(y_phi.signal{1}, [], 3);
		end
		for k2 = 0:numel(filters_rot.psi.filter)-1
			psi_angle = filters_rot.psi.filter{k2+1};
			ds = max(k2/filters_rot.Q - oversampling_rot, 0);
			y_Psi.signal{p} = ...
				sub_conv_1d_along_third_dim_simple(y_phi_f, psi_angle, ds);
			y_Psi.meta.j2(p) = J;
			y_Psi.meta.theta2(p) = 0;
			y_Psi.meta.k2(p) = k2;
			p = p + 1;
		end
		
		
		%%%%%%%%%%%%%%%%%%
		%%% psi - phi %%%%
		%%%%%%%%%%%%%%%%%%
		%      AND       %
		%%%%%%%%%%%%%%%%%%
		%%% psi - phi %%%%
		%%%%%%%%%%%%%%%%%%
		
		%% high pass spatial - with pyramid
		if (strcmp(angular_range, 'zero_pi') && angular_res == 0)
			g = filters.g.filter;
			
			for j2 = j_min:J-1
				for theta2 = 1:L
					for theta = 1:L
						% convolution with psi_{j1, theta + theta2}
						theta_sum_mod2L =  1 + mod(theta + theta2 - 2, 2*L);
						theta_sum_modL =  1 + mod(theta + theta2 - 2, L);
						tmp_slice = convsub2d_spatial(hy.signal{j2+1}(:,:,theta), g{theta_sum_modL}, 0);
						if (theta2 == 1) % allocate
							tmp = zeros([size(tmp_slice), 2*L]);
						end
						if (theta_sum_mod2L <= L)
							tmp(:,:,theta) = tmp_slice;
							tmp(:,:,theta+L) = conj(tmp_slice);
						else
							tmp(:,:,theta) = conj(tmp_slice);
							tmp(:,:,theta+L) = tmp_slice;
						end
					end
					
					% tmp can now be filtered along the orientation
					tmp_f = fft(tmp, [], 3);
					%% low pass angle
					ds = min(2*L, max(filters_rot.J/filters_rot.Q - oversampling_rot, 0));
					if (2^ds == 2*L)
						% faster to compute the sum along the angle
						y_Psi.signal{p} = sum(tmp, 3) / 2^(ds/2);
					else
						y_Psi.signal{p} = ...
							sub_conv_1d_along_third_dim_simple(tmp_f, phi_angle, ds);
					end
					y_Psi.meta.j2(p) = j2;
					y_Psi.meta.theta2(p) = theta2;
					y_Psi.meta.k2(p) = filters_rot.J;
					p = p + 1;
					
					%% high pass angle
					for k2 = 0:numel(filters_rot.psi.filter)-1
						psi_angle = filters_rot.psi.filter{k2+1};
						ds = max(k2/filters_rot.Q - oversampling_rot, 0);
						y_Psi.signal{p} = ...
							sub_conv_1d_along_third_dim_simple(tmp_f, psi_angle, ds);
						y_Psi.meta.j2(p) = j2;
						y_Psi.meta.theta2(p) = theta2;
						y_Psi.meta.k2(p) = k2;
						p = p + 1;
					end
					
					
					
					
				end
			end
		else
			error('not yet supported');
		end
		
		
	end
end

