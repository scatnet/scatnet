% wavelet_1d: 1D wavelet transform.
% Usage
%    [x_phi, x_psi, meta_phi, meta_psi] = wavelet_1d(x, filters, options)
% Input
%    x: The signal to be transformed.
%    filters: The filters of the wavelet transform.
%    options: Various options for the transform. options.oversampling controls
%       the oversampling factor when subsampling.
% Output
%    x_phi: x filtered by lowpass filter phi
%    x_psi: cell array of x filtered by wavelets psi
%    meta_phi, meta_psi: meta information on x_phi and x_psi, respectively

function [x_phi, x_psi, meta_phi, meta_psi] = wavelet_1d(x, filters, options)
	if nargin < 3
		options = struct();
	end

	options = fill_struct(options, 'oversampling', 1);
	options = fill_struct(options, ...
		'psi_mask', true(1, numel(filters.psi.filter)));
	options = fill_struct(options, 'x_resolution',0);
	options = fill_struct(options, 'phi_renormalize',0);
	options = fill_struct(options, 'renormalize_epsilon',2^(-20));
	
	N = size(x,1);
	
	[temp,psi_bw,phi_bw] = filter_freq(filters);
	
	%N_padded = filters.N/2^(floor(log2(filters.N/(2*N))));
	N_padded = filters.N/2^options.x_resolution;
	
	% resolution of x - how much have we subsampled by?
	j0 = log2(filters.N/N_padded);
	
	x = reshape(x, [size(x,1), size(x,3)]);
	
	x = pad_signal_1d(x, N_padded, filters.boundary);
	
	xf = fft(x,[],1);
	
	ds = round(log2(2*pi/phi_bw)) - ...
	     j0 - ...
	     options.oversampling;
	ds = max(ds, 0);
	
	x_phi = real(conv_sub_1d(xf, filters.phi.filter, ds));
	x_phi = unpad_signal_1d(x_phi, ds, N);
	meta_phi.j = -1;
	meta_phi.bandwidth = phi_bw;
	meta_phi.resolution = ds;
	
	x_phi = reshape(x_phi, [size(x_phi,1) 1 size(x_phi,2)]);
	
	if options.phi_renormalize
		x_renorm = real(conv_sub_1d(xf, filters.phi.filter, 0));
		x = x./(x_renorm+options.renormalize_epsilon*2^(j0/2));
		xf = fft(x,[],1);
	end
	
	x_psi = cell(1, numel(filters.psi.filter));
	meta_psi.j = -1*ones(1, numel(filters.psi.filter));
	meta_psi.bandwidth = -1*ones(1, numel(filters.psi.filter));
	meta_psi.resolution = -1*ones(1, numel(filters.psi.filter));
	for p1 = find(options.psi_mask)
		ds = round(log2(2*pi/psi_bw(p1)/2)) - ...
		     j0 - ...
		     options.oversampling;
		ds = max(ds, 0);
		
		x_psi{p1} = conv_sub_1d(xf, filters.psi.filter{p1}, ds);
		x_psi{p1} = unpad_signal_1d(x_psi{p1}, ds, N);
		meta_psi.j(:,p1) = p1-1;
		meta_psi.bandwidth(:,p1) = psi_bw(p1);
		meta_psi.resolution(:,p1) = ds;
		
		x_psi{p1} = reshape(x_psi{p1}, [size(x_psi{p1},1) 1 size(x_psi{p1},2)]);
	end
end
