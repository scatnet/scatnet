% MORLET_FILTER_BANK_2D_PYRAMID Compute a bank of Morlet wavelet filters in
% the spatial domain.
%
% Usage
%	filters = MORLET_FILTER_BANK_2D_PYRAMID(options)
%
% Input
%    options (structure): Options of the bank of filters. Optional, with
%    fields:
%       Q (numeric): number of scale per octave
%       P (numeric): size of the filter
%       L (numeric): number of orientations
%       sigma_phi (numeric): standard deviation of the low pass phi_0
%       sigma_psi (numeric): standard deviation of the envelope of the
%       high-pass psi_0
%       xi_psi (numeric): the frequency peak of the high-pass psi_0
%       slant_psi (numeric): excentricity of the elliptic enveloppe of the
%       high-pass psi_0 (the smaller slant, the larger orientation
%       resolution)
%       precision (string): 'single' or 'double'
%
% Output
%    filters (struct):  filters, with the fields
%        g (struct): high-pass filter g, with the following fields:
%            filter (cell): cell of structure containing the coefficients
%            type (string): takes the value 'spatial_support'
%        h (struct): low-pass filter h
%            filter (cell): cell of structure containing the coefficients
%            type (string): takes the value 'spatial_support'
%        meta (struct): contains meta-information on (g,h)
%
% Description
%    Compute the Morlet filter bank in the spatial domain. 

function filters = morlet_filter_bank_2d_pyramid(options)
    if(nargin<1)
		options = struct;
    end
    
    white_list = {'Q', 'L', 'P', 'sigma_phi','sigma_psi','xi_psi','slant_psi','precision'};
    check_options_white_list(options, white_list);
    
    % Options
    options = fill_struct(options, 'Q',1);	
    options = fill_struct(options, 'L',8);
    Q = options.Q;
    L = options.L;
	options = fill_struct(options, 'sigma_phi',  0.8);	
    options = fill_struct(options, 'sigma_psi',  0.8);	
    options = fill_struct(options, 'xi_psi',  1/2*(2^(-1/Q)+1)*pi);	
    options = fill_struct(options, 'slant_psi',  4/L);	
    options = fill_struct(options, 'P',  3);	
    P = options.P;
	
    % then the filter is in 32 bits float.
    options = fill_struct(options, 'precision', 'single');	
	precision = options.precision;
	
    
	
	sigma_phi = options.sigma_phi;
    sigma_psi = options.sigma_psi;
    xi_psi = options.xi_psi;
    slant_psi = options.slant_psi;
    
    
    
	% low pass filter h
	
	h.filter.coefft = gaussian_2d(2*P+1,...
		2*P+1,...
		sigma_phi,...
		precision);
    h.filter.coefft = h.filter.coefft./sum(h.filter.coefft(:));
	h.filter.type = 'spatial_support';
	
	angles = (0:L-1)  * pi / L;
	p = 1;
	
	% high pass filters g
	for q = 0:Q-1
		for theta = 1:numel(angles)
			
			angle = angles(theta);
			scale = 2^(q/Q);
			
			g.filter{p}.coefft = morlet_2d_pyramid(2*P+1,...
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
