% wavelet_2d : Compute the wavelet transform of an image
%
% Usage
%	[x_phi, x_psi] = wavelet_2d(x, filters)

function [x_phi, x_psi] = wavelet_2d(x, filters, options)
	
	if nargin<3
		options = struct();
	end
	
	precision_4byte = getoptions(options, 'precision_4byte', 1);
	
	% option retrieving
	oversampling = getoptions(options, 'oversampling', 1);
	psi_mask = getoptions(options, 'psi_mask', ones(1,numel(filters.psi.filter)));
	
	% precomputation
	lastres = log2(filters.meta.size_in(1)/size(x,1));
	margins = filters.meta.margins / 2^lastres;
	% mirror padding and fft
	xf = fft2(pad_signal_1d(x, filters.meta.size_filter/2^lastres, [], 0));
	
	Q = filters.meta.Q;
	
	% low pass filtering, downsampling and unpading
	J = filters.phi.meta.J;
	ds = max(floor(J/Q)- lastres - oversampling, 0);
	margins = filters.meta.margins / 2^(lastres+ds);
	x_phi = real(conv_sub_unpad_2d(xf, filters.phi.filter, ds, [0 0]));
	x_phi = unpad_signal_1d(x_phi, (lastres+ds)*[1 1], size(x));
	
	% high pass filtering, downsampling and unpading
	x_psi = {};
	for p = find(psi_mask)
		j = filters.psi.meta.j(p);
		ds = max(floor(j/Q)- lastres - oversampling, 0);
		margins = filters.meta.margins / 2^(lastres+ds);
		x_psi{p} = conv_sub_unpad_2d(xf, filters.psi.filter{p}, ds, [0 0]);
		x_psi{p} = unpad_signal_1d(x_psi{p}, (lastres+ds)*[1 1], size(x));
	end
	
	if(precision_4byte)
		x_phi = single(x_phi);
		x_psi = cellfun(@single, x_psi, 'UniformOutput', 0);
	end
	
end