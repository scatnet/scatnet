% wavelet_layer_1d: 1D wavelet transform layer.
% Usage
%    [U_phi , U_psi] = wavelet_layer_1d(U, filters, options)
% Input
%    U: The input layer to be transformed.
%    filters: The filters of the wavelet transform.
%    options: Various options for the transform. options.antialiasing controls
%       the antialiasing factor when subsampling.
% Output
%    U_phi The coefficients of in, lowpass-filtered (scattering coefficients).
%    U_psi: The wavelet transform coefficients.

function [U_phi, U_psi] = wavelet_layer_1d(U, filters, options)
	if nargin < 3
		options = struct();
	end
	
	calc_U = (nargout>=2);

	[psi_xi,psi_bw,phi_bw] = filter_freq(filters);
	
	if ~isfield(U.meta, 'bandwidth'), U.meta.bandwidth = 2*pi; end
	if ~isfield(U.meta, 'resolution'), U.meta.resolution = 0; end
	
	U_phi.signal = {};
	U_phi.meta.bandwidth = [];
	U_phi.meta.resolution = [];
	U_phi.meta.j = zeros(size(U.meta.j,1),0);
	
	U_psi.signal = {};
	U_psi.meta.bandwidth = [];
	U_psi.meta.resolution = [];
	U_psi.meta.j = zeros(size(U.meta.j,1)+1,0);
	
	r = 1;
	for p1 = 1:length(U.signal)
		psi_mask = calc_U&(U.meta.bandwidth(p1)>psi_xi);
		
		options.psi_mask = psi_mask;
		[x_phi, x_psi, meta_phi, meta_psi] = ...
			wavelet_1d(U.signal{p1}, filters, options);
		
		U_phi.signal{1,p1} = x_phi;
		U_phi.meta.bandwidth(1,p1) = meta_phi.bandwidth;
		U_phi.meta.resolution(1,p1) = U.meta.resolution(p1)+...
			meta_phi.resolution;
		U_phi.meta.j(:,p1) = U.meta.j(:,p1);
		
		ind = r:r+sum(psi_mask)-1;
		U_psi.signal(1,ind) = x_psi(psi_mask);
		U_psi.meta.bandwidth(1,ind) = meta_psi.bandwidth(psi_mask);
		U_psi.meta.resolution(1,ind) = U.meta.resolution(p1)+meta_psi.resolution(psi_mask);
		U_psi.meta.j(:,ind) = [U.meta.j(:,p1)*ones(1,length(ind)); ...
			meta_psi.j(psi_mask)];
			
		r = r+length(ind);
	end
end
