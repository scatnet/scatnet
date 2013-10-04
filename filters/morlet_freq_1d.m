function [psi_xi,psi_bw,phi_bw] = morlet_freq_1d(filter_options)
	sigma0 = 2/sqrt(3);
	
	% Calculate logarithmically spaced filters.
	for j1 = 0:filter_options.J-1
		psi_center(j1+1) = filter_options.xi_psi*2^(-j1/filter_options.Q);
		psi_sigma(j1+1) = filter_options.sigma_psi*2^(j1/filter_options.Q);
	end

	% Calculate linearly spaced filters so that they evenly cover the
	% remaining part of the spectrum
	step = pi*2^(-filter_options.J/filter_options.Q)*(1-1/4*sigma0/filter_options.sigma_phi*2^(1/filter_options.Q))/filter_options.P;
	for k1 = 0:filter_options.P-1
		psi_center(filter_options.J+k1+1) = ...
			filter_options.xi_psi*2^((-filter_options.J+1)/filter_options.Q)-step*(k1+1);
		psi_sigma(filter_options.J+k1+1) = filter_options.sigma_psi*2^((filter_options.J-1)/filter_options.Q);
	end

	phi_sigma = filter_options.sigma_phi*2^((filter_options.J-1)/filter_options.Q);

	% convert (spatial) sigmas to (frequential) bws
	psi_xi = psi_center;
	psi_bw = pi/2*sigma0./psi_sigma;
	if ~filter_options.phi_dirac
		phi_bw = pi/2*sigma0./phi_sigma;
	else
		phi_bw = 2*pi;
	end
end
