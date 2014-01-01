% INVERSE_SCAT Reconstruct a signal from its scattering coefficients
%
% Usage
%    [xt, Ut] = inverse_scat(S, filters, options, node, Ut)
%
% Input
%    S (cell): The scattering coefficients output by SCAT.
%    filters (cell): The set of filter banks used to calculate S. Can be
%        obtained from FILTER_BANK or second output of WAVELET_FACTORY_1D.
%    options (struct, optional): Specifies different parameters for the 
%        inversion. These are passed on to GRIFFIN_LIM and RICHARDSON_LUCY, so
%        please see the documentation for these functions for specific 
%        parameter settings. The parameter settings used by INVERSE_SCAT are:
%           oversampling (integer): The amount of oversampling used when
%              determining the resolution of a signal with respect to its
%              critical sampling rate, expressed as a power of 2 (default 1).
%           verbose (boolean): If true, shows computational information.
%    node (numeric, optional): A vector of the form [m p], where m is the 
%        coefficient to recover and p is its index. If [S,U] is the output of
%        the SCAT function, this corresponds to estimating U{m+1}.singal{p}.
%        To recover the original signal, node is therefore [0 1] (Default 
%        [0 1])
%    Ut (cell array, optional): A cell array of layers, representing the coef-
%        icients already estimated. If a coefficient is already present in Ut,
%        INVERSE_SCAT will use them instead of estimating them.
%
% Output
%    xt (numeric): The reconstructed signal.
%    Ut (cell array): A cell array of layers containing the wavelet modulus 
%       coefficients estimated by the algorithm, added to those provided as
%       input in Ut, if present.
%
% Description
%    The scattering transform is inverted recursively, estimating 
%    U{m+1}.signal{p} for each layer, starting with the last and propagating
%    upwards until U{1}.signal{1} is obtained, which is an estimate of the 
%    original signal.
%
%    For the last layer m = l, the Richardson-Lucy deconvolution algorithm is 
%    applied to estimate U{l+1}.signal{p} from S{l+1}.signal{p}. Previous
%    layers are reconstructed through the Griffin & Lim algorithm, with the
%    estimate of U{m+1}.signal{p1} are obtained from the estimates of 
%    U{m+2}.signal{p2}, where p2 correspond to the wavelet modulus coeffi-
%    cients in layer m+1 of the coefficient p1 in layer m -- the former being
%    the "children" of the latter.
%
% See also 
%   GRIFFIN_LIM, INVERSE_WAVELET_1D, RICHARDSON_LUCY

function [xt,Ut] = inverse_scat(S, filters, options, node, Ut)
	if nargin < 3
		options = [];
	end

	if nargin < 4
		node = [0 1];
	end
	
	if nargin < 5
		Ut = cell(size(S));
		for m0 = 0:length(Ut)-1
			Ut{m0+1}.signal = cell(size(S{m0+1}.signal));
			Ut{m0+1}.meta = struct();
			field_names = fieldnames(S{m0+1}.meta);
			for k = 1:length(field_names)
				Ut{m0+1}.meta = setfield(Ut{m0+1}.meta, field_names{k}, ...
					zeros(size(getfield(S{m0+1}.meta, field_names{k}),1),0));
			end
		end
	end
	
	if isempty(options)
		options = struct();
	end

	options = fill_struct(options, 'oversampling', 1);
	options = fill_struct(options, 'verbose', 0);

	m = node(1);
	p = node(2);

	if ~isempty(Ut{m+1}.signal{p})
		if options.verbose, fprintf('node [%d %d] is already estimated\n',m,p); end
		xt = Ut{m+1}.signal{p};
		return;
	end

	if options.verbose, fprintf('estimating node [%d %d]\n',m,p); end
	
	% find the filter bank used to calculate mth layer
	filt_ind = min(m+1,length(filters));
	
	% what's the original signal size?
	N0 = length(S{1}.signal{1})*2^S{1}.meta.resolution(1);
	if m > 0
		[psi_xi, psi_bw] = filter_freq(filters{min(max(m,1),length(filters))}.meta);
		bw = psi_bw(S{m+1}.meta.j(m,p)+1);
	else
		bw = 2*pi;
	end
	% what is the resolution, ie size, of the current coefficient?
	N = min(2^(-round(log2(2*pi/bw/2))+options.oversampling),1)*N0;
	
	j_node = S{m+1}.meta.j(:,p);
	
	if m < length(S)-1
		% intermediate layer, find children
		if ~isempty(j_node)
			children = find(all(bsxfun(@eq,S{m+2}.meta.j(1:m,:),j_node),1));
		else
			children = 1:length(S{m+2}.signal);
		end
	else
		% last layer, no children
		children = [];
	end
	
	x_phi = upsample(S{m+1}.signal{p}, N);
	
	if length(children) > 0
		% recurse on the children to estimate wavelet modulus coefficients,
		% then recover original signal using Griffin & Lim
		
		if options.verbose, fprintf('has children; recovering\n'); end
	
		for k = 1:length(children)
			j_child = S{m+2}.meta.j(m+1,children(k));
			if isempty(Ut{m+2}.signal{children(k)})
				[x_psi_mod{j_child+1},Ut] = inverse_scat(S, filters, ...
					options, [m+1 children(k)], Ut);
			else
				x_psi_mod{j_child+1} = Ut{m+2}.signal{children(k)};
			end
		end
	
		options1 = options;
		options1.x_resolution = log2(N0/N);
		options1.x_phi_resolution = log2(N0/N);

		if options.verbose, fprintf('applying Griffin & Lim\n'); end
		xt = griffin_lim(x_phi, x_phi, x_psi_mod, filters{filt_ind}, ...
			options1);
	else
		% no children, deconvolve using Richardson & Lucy
		
		if options.verbose, fprintf('no children; deconvolving\n'); end

		xt = richardson_lucy(x_phi, filters{filt_ind}.phi.filter, options);
	end
	
	Ut{m+1}.signal{p} = xt;
	Ut{m+1}.meta = map_meta(S{m+1}.meta, p, Ut{m+1}.meta, p, {'bandwidth', 'resolution'});
	Ut{m+1}.meta.bandwidth(1,p) = bw;
	Ut{m+1}.meta.resolution(1,p) = log2(N0/N);
end

