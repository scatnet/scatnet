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
	lastres = log2(filters.meta.size_in(1)/size(x,1));
	margins = filters.meta.margins / 2^lastres;
	% mirror padding and fft
	xf = fft2(pad_mirror_2d(x, margins));
	
	v = filters.meta.v;
	
	% low pass filtering, downsampling and unpading
	J = filters.phi.meta.J;
	ds = max(floor(J/v)- lastres - antialiasing, 0);
	margins = filters.meta.margins / 2^(lastres+ds);
	x_phi = real(conv_sub_unpad_2d(xf, filters.phi.filter, ds, margins));
	
	% high pass filtering, downsampling and unpading
	x_psi = {};
	for p = find(psi_mask)
		j = filters.psi.meta.j(p);
		ds = max(floor(j/v)- lastres - antialiasing, 0);
		margins = filters.meta.margins / 2^(lastres+ds);
		x_psi{p} = conv_sub_unpad_2d(xf, filters.psi.filter{p}, ds, margins);
	end
	
end