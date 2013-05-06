% wavelet_2d : Compute the wavelet transform of an image
%
% Usage
%	[x_phi, x_psi] = wavelet_2d(x, filters)	

function [x_phi, x_psi] = wavelet_2d(x, filters, options)
	
	if nargin<3
		options = struc();
	end
	
	% option retrieving
	antialiasing = getoptions(options, 'antialiasing', 1);
	psi_mask = getoptions(options, 'psi_mask', ones(1,numel(filters.psi.filter)));
	
	% precomputation
	xf = fft2(x);
	lastres = log2(filters.meta.size_in(1)/size(x,1));
	v = filters.meta.v;
	
	% low pass filtering and downsampling
	J = filters.phi.meta.J;
	ds = max(floor(J/v)- lastres - antialiasing, 0);
	x_phi = real(conv_sub_2d(xf, filters.phi.filter, ds));
	
	% high pass filtering and downsampling
	x_psi = {};
	for p = find(psi_mask)
		j = filters.psi.meta.j(p);
		ds = max(floor(j/v)- lastres - antialiasing, 0);
		x_psi{p} = conv_sub_2d(xf, filters.psi.filter{p}, ds);
	end
	
end