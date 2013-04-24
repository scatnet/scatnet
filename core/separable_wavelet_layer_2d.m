function [U_phi, U_psi] = separable_wavelet_layer_2d(U, filters, options)
	if nargin < 3
		options = struct();
	end
	
	calc_U = (nargout>=2);

	[psi1_xi,psi1_bw,phi1_bw] = filter_freq(filters{1});
	[psi2_xi,psi2_bw,phi2_bw] = filter_freq(filters{2});
	
	if ~isfield(U.meta, 'bandwidth'), U.meta.bandwidth = 2*pi*ones(2,1); end
	if ~isfield(U.meta, 'resolution'), U.meta.resolution = 0*ones(2,1); end
	if ~isfield(U.meta, 'j1'), U.meta.j1 = zeros(0,1); end
	if ~isfield(U.meta, 'j2'), U.meta.j2 = zeros(0,1); end
	
	U_phi.signal = {};
	U_phi.meta.bandwidth = [];
	U_phi.meta.resolution = [];
	U_phi.meta.j1 = zeros(size(U.meta.j1,1),0);
	U_phi.meta.j2 = zeros(size(U.meta.j2,1),0);
	
	U_psi.signal = {};
	U_psi.meta.bandwidth = [];
	U_psi.meta.resolution = [];
	U_psi.meta.j1 = zeros(size(U.meta.j1,1)+1,0);
	U_psi.meta.j2 = zeros(size(U.meta.j2,1)+1,0);
	
	r = 1;
	for p1 = 1:length(U.signal)
		options.psi_mask{1} = calc_U&(U.meta.bandwidth(1,p1)>psi1_xi);
		options.psi_mask{2} = calc_U&(U.meta.bandwidth(2,p1)>psi2_xi);
		
		[x_phi, x_psi] = separable_wavelet_2d(U.signal{p1}, filters, options);
		
		U_phi.signal{1,p1} = x_phi;
		U_phi.meta.bandwidth(1,p1) = phi1_bw;
		U_phi.meta.bandwidth(2,p1) = phi2_bw;
		U_phi.meta.resolution(1,p1) = log2(filters{1}.N/size(x_phi,1));
		U_phi.meta.resolution(2,p1) = log2(filters{2}.N/size(x_phi,2));
		U_phi.meta.j1(:,p1) = U.meta.j1(:,p1);
		U_phi.meta.j2(:,p1) = U.meta.j2(:,p1);
		
		nz = find(~cellfun(@isempty,x_psi));
		
		psi1_bw = [psi1_bw phi1_bw];
		psi2_bw = [psi2_bw phi2_bw];
		
		for p2 = nz(:)'
			[j1,j2] = ind2sub(size(x_psi),p2);
			U_psi.signal{1,r} = x_psi{p2};
			U_psi.meta.bandwidth(1,r) = psi1_bw(j1);
			U_psi.meta.bandwidth(2,r) = psi2_bw(j2);
			U_psi.meta.resolution(1,r) = log2(filters{1}.N/size(x_psi{p2},1));
			U_psi.meta.resolution(2,r) = log2(filters{2}.N/size(x_psi{p2},2));
			U_psi.meta.j1(:,r) = [U.meta.j1(:,p1); j1-1];
			U_psi.meta.j2(:,r) = [U.meta.j2(:,p1); j2-1];
			
			r = r+1;
		end
	end
end
