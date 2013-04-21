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
	U_phi.meta.j = zeros(0,size(U.meta.j,2));
	
	U_psi.signal = {};
	U_psi.meta.bandwidth = [];
	U_psi.meta.resolution = [];
	U_psi.meta.j = zeros(0,size(U.meta.j,2)+1);
	
	r = 1;
	for p1 = 1:length(U.signal)
		options.psi_mask = calc_U&(U.meta.bandwidth(p1)>psi_xi);
		
		[x_phi, x_psi] = wavelet_1d(U.signal{p1}, filters, options);
		
		U_phi.signal{p1} = x_phi;
		U_phi.meta.bandwidth(p1,1) = phi_bw;
		U_phi.meta.resolution(p1,1) = log2(filters.N/size(x_phi,1));
		U_phi.meta.j(p1,:) = U.meta.j(p1,:);
		
		for p2 = find(~cellfun(@isempty,x_psi))
			U_psi.signal{r} = x_psi{p2};
			U_psi.meta.bandwidth(r,1) = psi_bw(p2);
			U_psi.meta.resolution(r,1) = log2(filters.N/size(x_psi{p2},1));
			U_psi.meta.j(r,:) = [U.meta.j(p1,:) p2-1];
			
			r = r+1;
		end
	end
end
