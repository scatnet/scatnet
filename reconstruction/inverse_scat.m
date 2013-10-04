% INVERSE_SCAT Reconstruct a signal from its scattering coefficients
%
% Usage
%    xt = inverse_scat(S, filters, options, node)
%
% Input
%    S (cell): The scattering coefficients output by SCAT.
%    filters (cell): The set of filter banks used to calculate S. Can be
%        obtained from FILTER_BANK or second output of WAVELET_FACTORY_1D.
%    options (struct, optional): Specifies different parameters for the 
%        inversion. These are passed on to GRIFFIN_LIM and RICHARDSON_LUCY, so
%        please see the documentation for these functions for specific 
%        parameter settings.
%    node (numeric, optional): A vector of the form [m p], where m is the 
%        coefficient to recover and p is its index. If [S,U] is the output of
%        the SCAT function, this corresponds to estimating U{m+1}.singal{p}.
%        To recover the original signal, node is therefore [0 1] (Default 
%        [0 1])
%
% Output
%    xt (numeric): The reconstructed signal.
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

function xt = inverse_scat(S, filters, options, node)	
	if nargin < 3
		options = [];
	end

	if nargin < 4
		node = [0 1];
	end
	
	if isempty(options)
		options = struct();
	end
	
	% TODO: we don't always want to upsample/deconvolve/griffin&lim to highest
	% resolution, this should depend on where we are in the cascade
	N0 = length(S{1}.signal{1})*2^S{1}.meta.resolution(1);
	
	m = node(1);
	p = node(2);
	
	% find the filter bank used to calculate mth layer
	filt_ind = min(m+1,length(filters));
	
	j_node = S{m+1}.meta.j(:,p);
	
	if m < length(S)-1
		% intermediate layer, find children
		if ~isempty(j_node)
			children = find(all(S{m+2}.meta.j(1:m,:)==j_node,1));
		else
			children = 1:length(S{m+2}.signal);
		end
	else
		% last layer, no children
		children = [];
	end
	
	x_phi = upsample(S{m+1}.signal{p}, N0);
	
	if length(children) > 0
		% recurse on the children to estimate wavelet modulus coefficients,
		% then recover original signal using Griffin & Lim
	
		for k = 1:length(children)
			j_child = S{m+2}.meta.j(m+1,children(k));
			x_psi_mod{j_child+1} = inverse_scat(S, filters, options, ...
				[m+1 children(k)]);
		end
	
		% TODO: we don't always need this, do we?
		options1.oversampling = 100;
	
		xt = griffin_lim(x_phi, x_phi, x_psi_mod, filters{filt_ind}, ...
			options1);
	else
		% no children, deconvolve using Richardson & Lucy

		xt = richardson_lucy(x_phi, filters{filt_ind}.phi.filter, options);
	end
end