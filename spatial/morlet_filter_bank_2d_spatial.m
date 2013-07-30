% morlet_filter_bank_2d : Build a bank of Morlet wavelet filters
%
% Usage
%	filters = morlet_filter_bank_2d(size_in, options)
%
% Input
% - size_in : <1x2 int> size of the input of the scattering
% - options : [optional] <1x1 struct> contains the following optional fields
%   - Q          : <1x1 int> the number of scale per octave
%   - J          : <1x1 int> the total number of scale.
%   - L   : <1x1 int> the number of orientations
%   - sigma_phi  : <1x1 double> the width of the low pass phi_0
%   - sigma_psi  : <1x1 double> the width of the envelope
%                                   of the high pass psi_0
%   - xi_psi     : <1x1 double> the frequency peak
%                                   of the high_pass psi_0
%   - slant_psi  : <1x1 double> the excentricity of the elliptic
%  enveloppe of the high_pass psi_0 (the smaller slant, the larger
%                                      orientation resolution)
%   - margins    : <1x2 int> the horizontal and vertical margin for
%                             mirror pading of signal
%
% Output
% - filters : <1x1 struct> contains the following fields
%   - psi.filter{p}.type : <string> 'fourier_multires'
%   - psi.filter{p}.coefft{res+1} : <?x? double> the fourier transform
%                          of the p high pass filter at resolution res
%   - psi.meta.k(p,1)     : its scale index
%   - psi.meta.theta(p,1) : its orientation scale
%   - phi.filter.type     : <string>'fourier_multires'
%   - phi.filter.coefft
%   - phi.meta.k(p,1)
%   - meta : <1x1 struct> global parameters of the filter bank

function filters = morlet_filter_bank_2d_spatial(options)
	
	options.null = 1;
	
	Q = getoptions(options, 'Q', 1); % number of scale per octave
	L = getoptions(options, 'L', 8); % number of orientations
	
	sigma_phi  = getoptions(options, 'sigma_phi',  0.8);
	sigma_psi  = getoptions(options, 'sigma_psi',  0.8);
	xi_psi     = getoptions(options, 'xi_psi',  1/2*(2^(-1/Q)+1)*pi);
	slant_psi  = getoptions(options, 'slant_psi',  4/L);
	
	P = getoptions(options, 'P', 3); % the size of the support is 2*P + 1
	
	precision  = getoptions(options, 'precision', 'single');% if single
	% then the filter is in 32 bits float.
	
	% low pass filter h
	
	h.filter.coefft = gaussian_2d_spatial(2*P+1,...
		2*P+1,...
		sigma_phi,...
		precision);
	h.filter.type = 'spatial_support';
	
	angles = (0:L-1)  * pi / L;
	p = 1;
	
	% high pass filters g
	for q = 0:Q-1
		for theta = 1:numel(angles)
			
			angle = angles(theta);
			scale = 2^(q/Q);
			
			g.filter{p}.coefft = morlet_2d_spatial(2*P+1,...
				2*P+1, ...
				sigma_psi*scale,...
				slant_psi,...
				xi_psi/scale,...
				angle,...
				precision) ;
			g.filter{p}.type = 'spatial_support';
			
			g.meta.q(p) = q;
			g.meta.theta(p) = theta;
			p = p + 1;
			
		end
	end
	
	filters.h = h;
	filters.g = g;
	
	filters.meta.Q = Q;
	filters.meta.L = L;
	filters.meta.sigma_phi = sigma_phi;
	filters.meta.sigma_psi = sigma_psi;
	filters.meta.xi_psi = xi_psi;
	filters.meta.slant_psi = slant_psi;
	filters.meta.P = P;
	
	
end
