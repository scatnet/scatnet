% wavelet_1d: Thresholded 1D wavelet transform.
% Usage
%    [x_phi, x_psi, meta_phi, meta_psi] = threshold_wavelet_1d(x, ...
%       filters, options)
% Input
%    x: The signal to be transformed.
%    filters: The filters of the wavelet transform.
%    options: Various options for the transform. options.oversampling controls
%       the oversampling factor when subsampling. options.threshold specifies
%       the threshold used.
% Output
%    x_phi: x filtered by lowpass filter phi
%    x_psi: cell array of x filtered by wavelets psi
%    meta_phi, meta_psi: meta information on x_phi and x_psi, respectively

function [x_phi, x_psi, meta_phi, meta_psi] = threshold_wavelet_1d(x, ...
	filters, options)
	
	if nargin < 3
		options = struct();
	end

	options = fill_struct(options, 'threshold', 1e-4);
	
	[x_phi, x_psi, meta_phi, meta_psi] = wavelet_1d(x, filters, options);
	
	for p1 = find(~cellfun(@isempty, x_psi))
		res = meta_psi.resolution(p1);
		
		x_psi{p1 ...
		} = T_theta(x_psi{p1}, options.threshold*2^(res/2));
	end
end

function y = T_theta(x, theta)
	r = abs(x);
	r(r>theta) = r(r>theta)-theta;
	r(r<=theta) = 0;
	y = x./abs(x).*r;
end