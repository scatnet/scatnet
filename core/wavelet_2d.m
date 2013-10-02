% WAVELET_2D Compute the wavelet transform of a signal x
%
% Usage
%    [x_phi, x_psi] = WAVELET_2D(x, filters, options)
%
% Input
%    x (numeric): the input signal
%    filters (cell): cell containing the filters
%    options (structure): options of the wavelet transform
%
% Output
%    x_phi (cell): Low pass part of the wavelet transform
%    x_psi (cell): Wavelet coeffcients of the wavelet transform
%
% Description
%    WAVELET_2D computes a wavelet transform, using the signal and the
%    filters in the Fourier domain. The signal is padded in order to avoid
%    border effects.
%
%    The meta information concerning the signal x_phi, x_psi(scale, angle, 
%    resolution) can be found in meta_phi and meta_psi.
%
% See also 
%   WAVELET_2D, CONV_SUB_2D, WAVELET_FACTORY_2D_PYRAMID
function [x_phi, x_psi] = wavelet_2d(x, filters, options)
	
    if(nargin<3)
		options = struct;
    end
    
    white_list = {'x_resolution', 'precision', 'psi_mask','oversampling','M'};
    check_options_white_list(options, white_list);
    
    % Options
    options = fill_struct(options, 'x_resolution',0);	
    options = fill_struct(options, 'precision','single');
    options = fill_struct(options, 'oversampling',1);	
	options = fill_struct(options, 'psi_mask', ...
    ones(1,numel(filters.psi.filter)));
    
    precision = options.precision;
    oversampling = options.oversampling;
    psi_mask = options.psi_mask;
    
	% Size
	lastres = options.x_resolution;
	margins = filters.meta.margins / 2^lastres;
	
    % Padding and fft
	xf = fft2(pad_signal(x, filters.meta.size_filter/2^lastres, [], 0));
	Q = filters.meta.Q;
	
	% Low pass filtering, downsampling and unpading
	J = filters.phi.meta.J;
	ds = max(floor(J/Q)- lastres - oversampling, 0);
	margins = filters.meta.margins / 2^(lastres+ds);
	x_phi.signal{1} = real(conv_sub_2d(xf, filters.phi.filter, ds));
	x_phi.signal{1} = unpad_signal(x_phi.signal{1}, ds*[1 1], size(x));
	
	x_phi.meta.j = -1;
	x_phi.meta.theta = -1;
	x_phi.meta.resolution = lastres+ds;
	
	% high pass filtering, downsampling and unpading
	x_psi = struct;
	x_psi.meta.j = -1*ones(1, numel(filters.psi.filter));
	x_psi.meta.theta = -1*ones(1, numel(filters.psi.filter));
	x_psi.meta.resolution = -1*ones(1, numel(filters.psi.filter));
    x_psi.signal={};
	for p = find(psi_mask)
		j = filters.psi.meta.j(p);
		ds = max(floor(j/Q)- lastres - oversampling, 0);
		margins = filters.meta.margins / 2^(lastres+ds);
		x_psi.signal{p} = conv_sub_2d(xf, filters.psi.filter{p}, ds);
		x_psi.signal{p} = unpad_signal(x_psi.signal{p}, ds*[1 1], size(x));
		x_psi.meta.j(1,p) = filters.psi.meta.j(p);
		x_psi.meta.theta(1,p) = filters.psi.meta.theta(p);
		x_psi.meta.resolution(1,p) = lastres+ds;
    end
	
    
	if(strcmp(precision,'single'))
		x_phi.signal{1} = single(x_phi.signal{1});
		x_psi.signal = cellfun(@single, x_psi.signal, 'UniformOutput', 0);
	end
	
end