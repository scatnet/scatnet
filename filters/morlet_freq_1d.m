function [psi_xi,psi_bw,phi_bw] = morlet_freq_1d(filters)
	sigma0 = 2/sqrt(3);
	
	% Calculate logarithmically spaced filters.
	for j1 = 0:filters.meta.J-1
		psi_center(j1+1) = filters.meta.xi_psi*2^(-j1/filters.meta.Q);
		psi_sigma(j1+1) = filters.meta.sigma_psi*2^(j1/filters.meta.Q);
	end

	% Calculate linearly spaced filters so that they evenly cover the
	% remaining part of the spectrum
	step = pi*2^(-filters.meta.J/filters.meta.Q)*(1-1/4*sigma0/filters.meta.sigma_phi*2^(1/filters.meta.Q))/filters.meta.P;
	for k1 = 0:filters.meta.P-1
		psi_center(filters.meta.J+k1+1) = ...
			filters.meta.xi_psi*2^((-filters.meta.J+1)/filters.meta.Q)-step*(k1+1);
		psi_sigma(filters.meta.J+k1+1) = filters.meta.sigma_psi*2^((filters.meta.J-1)/filters.meta.Q);
	end

	phi_sigma = filters.meta.sigma_phi*2^((filters.meta.J-1)/filters.meta.Q);

	% convert (spatial) sigmas to (frequential) bws
	psi_xi = psi_center;
	psi_bw = pi/2*sigma0./psi_sigma;
	if ~filters.meta.phi_dirac
		phi_bw = pi/2*sigma0./phi_sigma;
	else
		phi_bw = 2*pi;
	end
end
