% WAVELET_LAYER_2D Compute the wavelet transform from the modulus wavelet
% coefficients of the previous layer of a scattering network
%
% Usage
%    [A, V] = WAVELET_LAYER_2D(U, filters, options)
%
% Input
%    U (numeric): input modulus wavelet coefficients.
%    filters (cell of function handles): Linear operators used to generate a new 
%       layer from the previous one.
%    options (structure): optionnal
%
% Output
%    A (cell): Averaged wavelet coefficients
%    V (cell): Wavelet coefficients of the next layer
%
% Description
%    Given inputs modulus wavelet coefficients corresponding to a layer, 
%    WAVELET_LAYER_2D computes the wavelet transform coefficients of the 
%    next layer using WAVELET_2D.
%
% See also 
%   WAVELET_2D, WAVELET_LAYER_1D

function [A, V] = wavelet_layer_2d(U, filters, options)
	
	calculate_psi = (nargout>=2); % do not compute any convolution
	% with psi if the user does get U_psi
	
	if ~isfield(U.meta,'theta')
		U.meta.theta = zeros(0,size(U.meta.j,2));
	end
	
	if ~isfield(U.meta, 'resolution'),
		U.meta.resolution = 0;
	end
	
	p2 = 1;
	for p = 1:numel(U.signal)
		x = U.signal{p};
		if (numel(U.meta.j)>0)
			j = U.meta.j(end,p);
		else
			j = -1E20;
		end
		
		% compute mask for progressive paths
		options.psi_mask = calculate_psi & ...
			(filters.psi.meta.j >= j + filters.meta.Q);
			
		% set resolution of signal
		options.x_resolution = U.meta.resolution(p);
		
		% compute wavelet transform
		[x_phi, x_psi] = wavelet_2d(x, filters, options);
		
		% copy signal and meta for phi
		A.signal{p} = x_phi.signal{1};
		A.meta.j(:,p) = [U.meta.j(:,p); filters.phi.meta.J];
		A.meta.theta(:,p) = U.meta.theta(:,p);
		A.meta.resolution(1,p) = x_phi.meta.resolution;
		
		% copy signal and meta for psi
		for p_psi = find(options.psi_mask)
			V.signal{p2} = x_psi.signal{p_psi};
			V.meta.j(:,p2) = [U.meta.j(:,p);...
				filters.psi.meta.j(p_psi)];
			V.meta.theta(:,p2) = [U.meta.theta(:,p);...
				filters.psi.meta.theta(p_psi)];
			V.meta.resolution(1,p2) = x_psi.meta.resolution(p_psi);
			p2 = p2 +1;
		end
		
	end
	
end
