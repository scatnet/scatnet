% MORLET_FILTER_BANK_2D Compute a bank of Morlet wavelet filters in
%    the Fourier domain.
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
%       sigma_phi (numeric): standard deviation of the low-pass mother
%          wavelet
%       sigma_psi (numeric): standard deviation of the envelope of the
%          high-pass psi_0
%       xi_psi (numeric): the frequency peak of the band-pass mother
%          wavelet
%       slant_psi (numeric): excentricity of the elliptic enveloppe of the
%          band-pass psi_0 (the smaller slant, the larger orientation
%          resolution)
%       margins (numeric): 1-by-2 vector for the horizontal and vertical 
%           margin for mirror pading of signal
%       precision (string): 'double' or 'single'
%
% Output
%    filters (struct):  filters, with the fields
%        psi (struct): band-pass filter psi, with the following fields:
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

    white_list = {'Q', 'L', 'J', 'sigma_phi', 'sigma_psi', ...
        'xi_psi', 'slant_psi', 'min_margin', 'precision'};
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
	options = fill_struct(options, 'filter_format', 'fourier_multires');
    options = fill_struct(options, 'min_margin', options.sigma_phi * 2^(J/Q) );
    options = fill_struct(options, 'precision', 'single');
    sigma_phi  = options.sigma_phi;
	sigma_psi  = options.sigma_psi;
	xi_psi     = options.xi_psi;
	slant_psi  = options.slant_psi;
	
    
    switch options.precision
        case 'single'
            prec = @(x)(single(x));
        case 'double'
            prec = @(x)(x);
        otherwise
            error('precision must be either double or single');
    end
    
    % Size
    res_max = floor(J/Q);
    size_filter = pad_size(size_in, options.min_margin, res_max);
	phi.filter.type = 'fourier_multires';
	
	% Compute all resolution of the filters
	res = 0;
	
	N = size_filter(1);
	M = size_filter(2);
	
	% Compute low-pass filters phi
	scale = 2^((J-1) / Q - res);
	filter_spatial =  gabor_2d(N, M, sigma_phi*scale, 1, 0, 0);
	phi.filter = prec(real(fft2(filter_spatial)));
	phi.meta.J = J;
	
	phi.filter = optimize_filter(phi.filter, 1, options);
	
	littlewood_final = zeros(N, M);
	% Compute band-pass filters psi
	angles = (0:L-1)  * pi / L;
	p = 1;
	for j = 0:J-1
		for theta = 1:numel(angles)			
			angle = angles(theta);
			scale = 2^(j/Q - res);
			filter_spatial = morlet_2d_noDC(N, ...
				M,...
				sigma_psi*scale,...
				slant_psi,...
				xi_psi/scale,...
				angle);
				
			psi.filter{p} = prec(real(fft2(filter_spatial)));
			
			littlewood_final = littlewood_final + ...
				abs(realize_filter(psi.filter{p})).^2;
			
			psi.meta.j(p) = j;
			psi.meta.theta(p) = theta;
			p = p + 1;
		end
	end
	
	% Second pass : renormalize psi by max of littlewood paley to have
	% an almost unitary operator
	% NB : phi must not be renormalized since we want its mean to be 1
	K = max(littlewood_final(:));
	for p = 1:numel(psi.filter)
		psi.filter{p} = psi.filter{p}/sqrt(K/2);
		psi.filter{p} = optimize_filter(psi.filter{p}, 0, options);
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
end
