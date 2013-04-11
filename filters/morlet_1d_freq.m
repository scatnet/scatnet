function [psi_xi,psi_bw,phi_bw] = morlet_1d_freq(filters)
	sigma0 = 2/sqrt(3);
	
	% Calculate logarithmically spaced filters.
	for j1 = 0:filters.J-1
		psi_center(j1+1) = filters.xi_psi*2^(-j1/filters.V);
		psi_sigma(j1+1) = filters.sigma_psi*2^(j1/filters.V);
	end

	% Calculate linearly spaced filters so that they evenly cover the
	% remaining part of the spectrum
	step = pi*2^(-filters.J/filters.V)*(1-1/4*sigma0/filters.sigma_phi*2^(1/filters.V))/filters.P;
	for k1 = 0:filters.P-1
		psi_center(filters.J+k1+1) = ...
			filters.xi_psi*2^((-filters.J+1)/filters.V)-step*(k1+1);
		psi_sigma(filters.J+k1+1) = filters.sigma_psi*2^((filters.J-1)/filters.V);
	end

	phi_sigma = filters.sigma_phi*2^((filters.J-1)/filters.V);

	% convert (spatial) sigmas to (frequential) bws
	psi_xi = psi_center;
	psi_bw = pi/2*sigma0./psi_sigma;
	phi_bw = pi/2*sigma0./phi_sigma;
end
