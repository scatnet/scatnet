% wavelet_1d: 1D wavelet transform.
% Usage
%    [x_phi, x_psi] = wavelet_1d(x, filters, options)
% Input
%    x: The signal to be transformed.
%    filters: The filters of the wavelet transform.
%    options: Various options for the transform. options.antialiasing controls
%       the antialiasing factor when subsampling.
% Output
%    x_phi: x filtered by lowpass filter phi
%    x_psi: cell array of x filtered by wavelets psi

function [x_phi, x_psi] = wavelet_1d(x, filters, options)
	if nargin < 3
		options = struct();
	end

	options = fill_struct(options, 'antialiasing', 1);
	options = fill_struct(options, ...
		'psi_mask', true(1, numel(filters.psi.filter)));
	
	N = size(x,1);
	
	[temp,psi_bw,phi_bw] = filter_freq(filters);
	
	j0 = log2(filters.N/N);
	
	xf = fft(x,[],1);
	
	ds = round(log2(2*pi/phi_bw)) - ...
	     j0 - ...
	     options.antialiasing;
	ds = max(ds, 0);
	
	x_phi = real(conv_sub_1d(xf, filters.phi.filter, ds));
	
	x_psi = cell(1, numel(filters.psi.filter));
	for p1 = find(options.psi_mask)
		ds = round(log2(2*pi/psi_bw(p1)/2)) - ...
		     j0 - ...
		     options.antialiasing;
		ds = max(ds, 0);
		
		x_psi{p1} = conv_sub_1d(xf, filters.psi.filter{p1}, ds);
	end
end
