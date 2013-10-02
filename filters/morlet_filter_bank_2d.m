% MORLET_FILTER_BANK_2D_PYRAMID Compute a bank of Morlet wavelet filters in
% the Fourier domain.
%
% Usage
%	filters = MORLET_FILTER_BANK_2D(size_in, options)
%
% Input
%    options (structure): Options of the bank of filters. Optional, with
%    fields:
%       Q (numeric): number of scale per octave
%       J (numeric): total number of scale.
%       L (numeric): number of orientations
%       sigma_phi (numeric): standard deviation of the low pass phi_0
%       sigma_psi (numeric): standard deviation of the envelope of the
%       high-pass psi_0
%       xi_psi (numeric): the frequency peak of the high-pass psi_0
%       slant_psi (numeric): excentricity of the elliptic enveloppe of the
%       high-pass psi_0 (the smaller slant, the larger orientation
%       resolution)
%       margins (numeric): 1-by-2 vector for the horizontal and vertical 
%       margin for mirror pading of signal
%
% Output
%    filters (struct):  filters, with the fields
%        psi (struct): high-pass filter psi, with the following fields:
%            filter (cell): cell of structure containing the coefficients
%            type (string): takes the value 'fourier_multires'
%        phi (struct): low-pass filter phi
%            filter (cell): cell of structure containing the coefficients
%            type (string): takes the value 'fourier_multires'
%        meta (struct): contains meta-information on (g,h)
%
% Description
%    Compute the Morlet filter bank in the Fourier domain.

function filters = morlet_filter_bank_2d(size_in, options)
    if(nargin<2)
		options = struct;
    end

	
    
    white_list = {'Q', 'L', 'J', 'sigma_phi','sigma_psi','xi_psi','slant_psi'};
    check_options_white_list(options, white_list);
    
    % Options
    options = fill_struct(options, 'Q',1);	
    options = fill_struct(options, 'L',8);
    options = fill_struct(options, 'J',4);
    J = options.J;
    Q = options.Q;
    L = options.L;
	options = fill_struct(options, 'sigma_phi',  0.8);	
    options = fill_struct(options, 'sigma_psi',  0.8);	
    options = fill_struct(options, 'sigma_psi',  0.8);	
    options = fill_struct(options, 'xi_psi',  1/2*(2^(-1/Q)+1)*pi);	
    options = fill_struct(options, 'slant_psi',  4/L);	
    
    sigma_phi  = options.sigma_phi;
	sigma_psi  = options.sigma_psi;
	xi_psi     = options.xi_psi;
	slant_psi  = options.slant_psi;
	
	res_max = floor(J/Q);
    
    
    % Default margin
    margins_default = 2*sigma_phi*2^((J-1)/Q);
	margins_default = min(2^res_max * ceil(margins_default/2^res_max), ...
		size_in);
	options = fill_struct(options, 'margins', margins_default);
    margins = options.margins;
    
    
	size_filter = size_in + margins;
	size_filter = ceil(size_filter/2^res_max)*2^res_max;
	
	phi.filter.type = 'fourier_multires';
	
	% compute all resolution of the filters
	for res = 0:res_max
		
		N = ceil(size_filter(1) / 2^res);
		M = ceil(size_filter(2) / 2^res);
		
		% compute low pass filters phi
		scale = 2^((J-1) / Q - res);
		filter_spatial =  gabor_2d(N, M, sigma_phi*scale, 1, 0, 0);
		phi.filter.coefft{res+1} = fft2(filter_spatial);
		phi.meta.J = J;
		
		littlewood_final = zeros(N, M);
		% compute high pass filters psi
		angles = (0:L-1)  * pi / L;
		p = 1;
		for j = 0:J-1
			for theta = 1:numel(angles)
				
				psi.filter{p}.type = 'fourier_multires';
				
				angle = angles(theta);
				scale = 2^(j/Q - res);
				if (scale >= 1)
					if (res==0)
						filter_spatial = morlet_2d_noDC(N, ...
							M,...
							sigma_psi*scale,...
							slant_psi,...
							xi_psi/scale,...
							angle) ;
						psi.filter{p}.coefft{res+1} = fft2(filter_spatial);
					else
						% no need to recompute : just downsample by periodizing in
						% fourier
						psi.filter{p}.coefft{res+1} = ...
							sum(extract_block(psi.filter{p}.coefft{1}, [2^res, 2^res]), 3) / 2^res;
						
					end
					littlewood_final = littlewood_final + abs(psi.filter{p}.coefft{res+1}).^2;
				end
				
				psi.meta.j(p) = j;
				psi.meta.theta(p) = theta;
				p = p + 1;
			end
		end
		
		% second pass : renormalize psi by max of littlewood paley to have
		% an almost unitary operator
		% NOTE : phi must not be renormalized since we want its mean to be 1
		K = max(littlewood_final(:));
		for p = 1:numel(psi.filter)
			if (numel(psi.filter{p}.coefft)>=res+1)
				psi.filter{p}.coefft{res+1} = psi.filter{p}.coefft{res+1} / sqrt(K/2);
			end
		end
	end
	
	filters.phi = phi;
	filters.psi = psi;
	
	filters.meta.Q = Q;
	filters.meta.J = J;
	filters.meta.L = L;
	filters.meta.sigma_phi = sigma_phi;
	filters.meta.sigma_psi = sigma_psi;
	filters.meta.xi_psi = xi_psi;
	filters.meta.slant_psi = slant_psi;
	filters.meta.size_in = size_in;
	filters.meta.size_filter = size_filter;
	filters.meta.margins = margins;
	
	
end
