% wavelet_2d : Compute the wavelet transform of an image
%
% Usage
%	[x_phi, x_psi] = wavelet_2d(x, filters)

function [x_phi, x_psi, meta_phi, meta_psi] = wavelet_2d(x, filters, options)
	if nargin<3
		options = struct();
	end
	
	options = fill_struct(options, 'x_resolution',0);
	
	precision_4byte = getoptions(options, 'precision_4byte', 1);
	
	% option retrieving
	oversampling = getoptions(options, 'oversampling', 1);
	psi_mask = getoptions(options, 'psi_mask', ones(1,numel(filters.psi.filter)));
	
	% precomputation
	lastres = options.x_resolution;
	margins = filters.meta.margins / 2^lastres;
	% mirror padding and fft
	xf = fft2(pad_signal_1d(x, filters.meta.size_filter/2^lastres, [], 0));
	
	Q = filters.meta.Q;
	
	% low pass filtering, downsampling and unpading
	J = filters.phi.meta.J;
	ds = max(floor(J/Q)- lastres - oversampling, 0);
	margins = filters.meta.margins / 2^(lastres+ds);
	x_phi = real(conv_sub_2d(xf, filters.phi.filter, ds));
	x_phi = unpad_signal_1d(x_phi, ds*[1 1], size(x));
	
	meta_phi.j = -1;
	meta_phi.theta = -1;
	meta_phi.resolution = lastres+ds;
	
	% high pass filtering, downsampling and unpading
	x_psi = {};
	meta_psi.j = -1*ones(1, numel(filters.psi.filter));
	meta_psi.theta = -1*ones(1, numel(filters.psi.filter));
	meta_psi.resolution = -1*ones(1, numel(filters.psi.filter));
	for p = find(psi_mask)
		j = filters.psi.meta.j(p);
		ds = max(floor(j/Q)- lastres - oversampling, 0);
		margins = filters.meta.margins / 2^(lastres+ds);
		x_psi{p} = conv_sub_2d(xf, filters.psi.filter{p}, ds);
		x_psi{p} = unpad_signal_1d(x_psi{p}, ds*[1 1], size(x));
		
		meta_psi.j(1,p) = filters.psi.meta.j(p);
		meta_psi.theta(1,p) = filters.psi.meta.theta(p);
		meta_psi.resolution(1,p) = lastres+ds;
	end
	
	if(precision_4byte)
		x_phi = single(x_phi);
		x_psi = cellfun(@single, x_psi, 'UniformOutput', 0);
	end
	
end