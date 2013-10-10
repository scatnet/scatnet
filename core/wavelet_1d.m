% WAVELET_1D One-dimensional wavelet transform
%
% Usages
%    [x_phi, x_psi, meta_phi, meta_psi] = WAVELET_1D(x, filters)
%
%    [x_phi, x_psi, meta_phi, meta_psi] = WAVELET_1D(x, filters, options)
%
% Input
%    x (numeric): The signal to be transformed.
%    filters (struct): The filter bank of the wavelet transform.
%    options (struct): Various options for the transform:
%       options.oversampling (int): The oversampling factor (as a power of 2) 
%          with respect to the critical bandwidth when calculating convolu-
%          tions (default 1).
%       options.psi_mask (boolean): Specifies the wavelet filters in 
%          filters.psi for which the transform is to be calculated (default 
%          all).
%       options.x_resolution (int): The resolution of the input signal x as
%          a power of 2, representing the downsampling of the signal with
%          respect to the finest resolution (default 0).
%
% Output
%    x_phi (numeric): x filtered by the lowpass filter filters.phi.
%    x_psi (cell): cell array of x filtered by the wavelets filters.psi.
%    meta_phi, meta_psi (struct): meta information on x_phi and x_psi, respec-
%       tively.
%
% See also
%    FILTER_BANK, WAVELET_LAYER_1D, WAVELET_FACTORY_1D, WAVELET_2D

function [x_phi, x_psi, meta_phi, meta_psi] = wavelet_1d(x, filters, options)
	if nargin < 3
		options = struct();
	end

	options = fill_struct(options, 'oversampling', 1);
	options = fill_struct(options, ...
		'psi_mask', true(1, numel(filters.psi.filter)));
	options = fill_struct(options, 'x_resolution',0);
	options = fill_struct(options, 'use_abs', 0);

	N = size(x,1);

	if size(x,2) > 1
		error(['Input x must be one-dimensional! Multiple signals can be ' ...
		'specified by letting x be of the form Nx1xK, where K is the ' ...
		'number of signals.']);
	end

	[temp,psi_bw,phi_bw] = filter_freq(filters);

	j0 = options.x_resolution;

	N_padded = filters.meta.size_filter/2^j0;

	x = reshape(x, [size(x,1), size(x,3)]);

	x = pad_signal(x, N_padded, filters.meta.boundary);

	xf = fft(x,[],1);

	  %It has been proven sometimes useful to renormalize the first order
    %coefficients of the scattering transform of an audio signal by its
    % mean, x_phi=conv(x,phi), but this value is typically nul for audio
    %so we rather renormalize by x_phi=conv(abs(x),phi). Putting
    %options.use_abs to 1 should be done in preparation of that fact.
    
     if options.use_abs==1 
        xf_abs=fft(abs(x),[],1);
        x_phi = real(conv_sub_1d(xf_abs, filters.phi.filter, ds));
     else 
        x_phi = real(conv_sub_1d(xf, filters.phi.filter, ds));
     end

	ds = round(log2(2*pi/phi_bw)) - j0 - options.oversampling;
	ds = max(ds, 0);

	x_phi = unpad_signal(x_phi, ds, N);
	meta_phi.j = -1;
	meta_phi.bandwidth = phi_bw;
	meta_phi.resolution = j0+ds;

	x_phi = reshape(x_phi, [size(x_phi,1) 1 size(x_phi,2)]);
    
	x_psi = cell(1, numel(filters.psi.filter));
	meta_psi.j = -1*ones(1, numel(filters.psi.filter));
	meta_psi.bandwidth = -1*ones(1, numel(filters.psi.filter));
	meta_psi.resolution = -1*ones(1, numel(filters.psi.filter));
	for p1 = find(options.psi_mask)
		ds = round(log2(2*pi/psi_bw(p1)/2)) - ...
			j0 - ...
			max(1, options.oversampling);
		ds = max(ds, 0);

		x_psi{p1} = conv_sub_1d(xf, filters.psi.filter{p1}, ds);
		x_psi{p1} = unpad_signal(x_psi{p1}, ds, N);
		meta_psi.j(:,p1) = p1-1;
		meta_psi.bandwidth(:,p1) = psi_bw(p1);
		meta_psi.resolution(:,p1) = j0+ds;

		x_psi{p1} = reshape(x_psi{p1}, [size(x_psi{p1},1) 1 size(x_psi{p1},2)]);
	end
end
