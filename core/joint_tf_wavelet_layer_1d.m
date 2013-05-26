function [U_phi, U_psi] = joint_wavelet_layer_1d(U, filters, options)
	if nargin < 3
		options = struct();
	end
	
	calc_U = (nargout>=2);
	
	if ~isfield(U.meta, 'bandwidth'), U.meta.bandwidth = 2*pi; end
	if ~isfield(U.meta, 'resolution'), U.meta.resolution = 0; end
	
	% filter along time, no modulus

	if calc_U
		[U_phi, U_psi] = wavelet_layer_1d(U, filters{2}, options);
	else
		U_phi = wavelet_layer_1d(U, filters{2}, options);
		U_psi.signal = {};
		U_psi.meta = struct();
		U_psi.meta.j = zeros(0,0);
	end
		
	Y_phi = concatenate_freq(U_phi);
	Y_psi = concatenate_freq(U_psi);
	
	if ~isfield(Y_phi.meta,'fr_j')
		Y_phi.meta.fr_j = zeros(0,size(Y_phi.meta.j,2));
	end
	
	if ~isfield(Y_psi.meta,'fr_j')
		Y_psi.meta.fr_j = zeros(0,size(Y_psi.meta.j,2));
	end
	
	U_phi.signal = {};
	U_phi.meta = struct();
	
	U_psi.signal = {};
	U_psi.meta = struct();
	U_psi.meta.fr_j = zeros(size(Y_phi.meta.fr_j,1)+1,0);
	U_psi.meta.j = zeros(size(Y_phi.meta.j,1)+1,0);

	r_phi = 1;
	r_psi = 1;
	p2 = 1;
	for s = 1:2
		if s == 1
			Z = Y_phi;
		else
			Z = Y_psi;
		end
		
		if ~isfield(Z.meta,'fr_resolution')
			Z.meta.fr_resolution = zeros(1,size(Z.meta.j,2));
		end
		
		r0 = 1;
		
		for p1 = 1:length(Z.signal)
			% actually use fr_bw to calc psi_mask etc.
			psi_mask = find(calc_U&true(size(filters{1}.psi.filter)));
		
			options.x_resolution = Z.meta.fr_resolution(p1);
			options.psi_mask = psi_mask;
		
			[Z_phi, Z_psi, meta_phi, meta_psi] = ...
				wavelet_1d(Z.signal{p1}, filters{1}, options);
			
			if s == 1
				ds = meta_phi.resolution;
				ind0 = r0:2^ds:r0+size(Z.signal{p1})-1;
				fr_count = size(Z_phi,1);
				U_phi.signal{p1} = Z_phi;
				ind_phi = r_phi:r_phi+fr_count-1;
		
				U_phi.meta = map_meta(Z.meta,ind0,U_phi.meta,ind_phi);
				U_phi.meta.fr_resolution(1,ind_phi) = Z.meta.fr_resolution(p1)+ds*ones(1,fr_count);
			
				r_phi = r_phi+length(r_phi);
			else
				Z_psi = [Z_psi Z_phi];
				psi_mask = [psi_mask length(Z_psi)];
				meta_psi = map_meta(meta_phi,1,meta_psi,length(Z_psi));
			end
		
			for k = psi_mask
				U_psi.signal{p2} = Z_psi{k};
				ds = meta_psi.resolution(k);
				ind0 = r0:2^ds:r0+size(Z.signal{p1},1)-1;
				fr_count = size(Z_psi{k},1);
				ind_psi = r_psi:r_psi+fr_count-1;
				U_psi.meta = map_meta(Z.meta,ind0,U_psi.meta,ind_psi,{'j','fr_j'});
				if s == 2
					U_psi.meta.j(:,ind_psi) = Z.meta.j(:,ind0);
				else
					U_psi.meta.j(:,ind_psi) = [Z.meta.j(:,ind0); length(filters{2}.psi.filter)*ones(1,fr_count)];
				end
				U_psi.meta.fr_j(:,ind_psi) = [Z.meta.fr_j(:,ind0); (k-1)*ones(1,fr_count)];
				U_psi.meta.fr_resolution(1,ind_psi) = Z.meta.fr_resolution(p1)+ds*ones(1,fr_count);
				r_psi = r_psi+length(ind_psi);
				p2 = p2+1;
			end
			
			r0 = r0+size(Z.signal{p1});
		end
	end	

	U_phi = separate_freq(U_phi);
	U_psi = separate_freq(U_psi);
end

%%% TODO
% - incorporate progressivity along frequency
