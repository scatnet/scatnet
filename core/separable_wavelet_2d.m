function [x_phi, x_psi, meta_phi, meta_psi] = separable_wavelet_2d(x, filters, options)
	if nargin < 3
		options = struct();
	end

	options = fill_struct(options, 'antialiasing', 1);
	options = fill_struct(options, ...
		'psi_mask', {true(1, numel(filters{1}.psi.filter)), ...
			true(1, numel(filters{2}.psi.filter))});
	options = fill_struct(options, 'x_resolution', [0; 0]);
			
	N_orig = size(x);
	N_orig = N_orig(1:2);
	
	N_padded(1) = filters{1}.N/2^options.x_resolution(1);
	N_padded(2) = filters{2}.N/2^options.x_resolution(2);
	
	x = pad_signal_1d(x, N_padded, 'symm');
	
	% along 1
	N = size(x,1);

	[temp,psi_bw,phi_bw] = filter_freq(filters{1});

	j0 = log2(filters{1}.N/N);

	xf = fft(x,[],1);
	
	x1 = cell(numel(filters{1}.psi.filter)+1,1);
	res1 = zeros(numel(filters{1}.psi.filter)+1,1);
	bw1 = zeros(numel(filters{1}.psi.filter)+1,1);
	for p1 = find(options.psi_mask{1})
		ds = round(log2(2*pi/psi_bw(p1)/2)) - ...
		     j0 - ...
		     options.antialiasing;
		ds = max(ds, 0);
	
		x1{p1,1} = conv_sub_1d(xf, filters{1}.psi.filter{p1}, ds);
		res1(p1,1) = ds;
		bw1(p1,1) = psi_bw(p1);
	end
	
	ds = round(log2(2*pi/phi_bw)) - ...
	     j0 - ...
	     options.antialiasing;
	ds = max(ds, 0);

	x1{end,1} = real(conv_sub_1d(xf, filters{1}.phi.filter, ds));
	res1(end,1) = ds;
	bw1(end,1) = phi_bw;
	
	% along 2
	N = size(x,2);

	[temp,psi_bw,phi_bw] = filter_freq(filters{2});

	j0 = log2(filters{2}.N/N);

	x2 = cell(numel(filters{1}.psi.filter)+1,numel(filters{2}.psi.filter)+1);
	res2 = zeros(1, numel(filters{2}.psi.filter)+1);
	bw2 = zeros(1, numel(filters{2}.psi.filter)+1);
	meta.j1 = -1*ones(1, numel(filters{1}.psi.filter)+1, numel(filters{2}.psi.filter)+1);
	meta.j2 = -1*ones(1, numel(filters{1}.psi.filter)+1, numel(filters{2}.psi.filter)+1);
	meta.bandwidth = -1*ones(2, numel(filters{1}.psi.filter)+1, numel(filters{2}.psi.filter)+1);
	meta.resolution = -1*ones(2, numel(filters{1}.psi.filter)+1, numel(filters{2}.psi.filter)+1);
	for p1 = 1:size(x1,1)
		if isempty(x1{p1})
			continue;
		end
		
		xf = fft(x1{p1},[],2);
		
		for p2 = find(options.psi_mask{2})
			ds = round(log2(2*pi/psi_bw(p2)/2)) - ...
			     j0 - ...
			     options.antialiasing;
			ds = max(ds, 0);

			x2{p1,p2} = permute(conv_sub_1d(permute(xf,[2 1 3]), filters{2}.psi.filter{p2}, ds),[2 1 3]);
			res2(1,p2) = ds;
			bw2(1,p2) = psi_bw(p2);
			x2{p1,p2} = unpad_signal_1d(x2{p1,p2}, [res1(p1) res2(p2)], N_orig);
			meta.j1(:,p1,p2) = p1-1;
			meta.j2(:,p1,p2) = p2-1;
			meta.bandwidth(:,p1,p2) = [bw1(p1) bw2(p2)];
			meta.resolution(:,p1,p2) = [res1(p1) res2(p2)];
		end

		ds = round(log2(2*pi/phi_bw)) - ...
		     j0 - ...
		     options.antialiasing;
		ds = max(ds, 0);

		x2{p1,end} = permute(real(conv_sub_1d(permute(xf,[2 1 3]), filters{2}.phi.filter, ds)),[2 1 3]);
		res2(1,end) = ds;
		bw2(1,end) = phi_bw;
		x2{p1,end} = unpad_signal_1d(x2{p1,end}, [res1(p1) res2(end)], N_orig);
		meta.j1(:,p1,end) = p1-1;
		meta.j2(:,p1,end) = numel(filters{2}.psi.filter)+1-1;
		meta.bandwidth(:,p1,end) = [bw1(p1) bw2(end)];
		meta.resolution(:,p1,end) = [res1(p1) res2(end)];
	end
	
	x_phi = x2{end,end};
	x2{end,end} = [];
	x_psi = x2;
	
	meta_phi.j1 = meta.j1(:,end,end);
	meta_phi.j2 = meta.j2(:,end,end);
	meta_phi.bandwidth = meta.bandwidth(:,end,end);
	meta_phi.resolution = meta.resolution(:,end,end);
	
	meta_psi = meta;
	meta_psi.j1(:,end,end) = [0];
	meta_psi.j2(:,end,end) = [0];
	meta_psi.bandwidth(:,end,end) = [0; 0];
	meta_psi.resolution(:,end,end) = [0; 0];
end
