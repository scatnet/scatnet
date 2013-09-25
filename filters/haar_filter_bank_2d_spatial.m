% morlet_filter_bank_2d : Build a bank of Morlet wavelet filters
%
% Usage
%	filters = morlet_filter_bank_2d(size_in, options)
%
% Input
% - size_in : <1x2 int> size of the input of the scattering
% - options : [optional] <1x1 struct> contains the following optional fields
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

function filters = morlet_filter_bank_2d_pyramid(options)
	
	options.null = 1;
	precision  = getoptions(options, 'precision', 'single');% if single
	% then the filter is in 32 bits float.
	
	% low pass filter h
	
	h.filter.coefft = [0 0 0;...
		0 1 1;...
		0 1 1];
	if (strcmp(precision, 'single'))
		h.filter.coefft = single(h.filter.coefft);
	end
	h.filter.type = 'spatial_support';
	
	% high pass filters g
	g.filter{1}.coefft = [0  0  0;...
		0  1  1;...
		0 -1 -1];
	g.filter{2}.coefft = [0  0  0;...
		0  1 -1;...
		0  1 -1];
	g.filter{3}.coefft = [0  0  0;...
		0  1 -1;...
		0 -1  1];
	
	for p =  1:3
		if (strcmp(precision, 'single'))
			g.filter{p}.coefft = single(g.filter{p}.coefft);
		end
		g.filter{p}.type = 'spatial_support';
		g.meta.q(p) = 0;
		g.meta.theta(p) = p;
	end
	
	filters.h = h;
	filters.g = g;
	
	filters.meta.Q = 1;
	filters.meta.L = 3;
	filters.meta.P = 1;
	
	
end
