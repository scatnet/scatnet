function [psi_xi,psi_bw,phi_bw] = spline_1d_freq(filters)
	xi0 = 3*pi/4;

	psi_xi = xi0.*2.^(-[0:filters.J-1]);
	psi_bw = pi/2.*2.^(-[0:filters.J-1]);

	phi_bw = pi*2^(-[filters.J-1]);
end
