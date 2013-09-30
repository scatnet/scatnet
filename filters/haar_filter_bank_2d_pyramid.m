% HAAR_FILTER_BANK_2D_PYRAMID Build a bank of Haar wavelet filters in the
% spatial domain
%
% Usage
%	 filters = HAAR_FILTER_BANK_2D_PYRAMID(options)
%
% Input
%    options (struct): optional
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
%    Compute the Haar wavelet filter bank in the spatial domain.
%
% See also
%   MORLET_FILTER_BANK_2D_PYRAMID


function filters = haar_filter_bank_2d_pyramid(options)
    if(nargin<1)
        options=struct;
    end

    white_list = {'precision'};
    check_options_white_list(options, white_list);
    options = fill_struct(options, 'precision','single');	
	
    % the filter is in 32 bits float.
    precision  = options.precision;
	
	
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
