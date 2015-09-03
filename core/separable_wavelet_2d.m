function [x_phi, x_psi, meta_phi, meta_psi] = separable_wavelet_2d(x, filters, options)
	if nargin < 3
		options = struct();
	end

	options = fill_struct(options, 'antialiasing', 1);
	options = fill_struct(options, ...
		'psi_mask', {true(1, numel(filters{1}.psi.filter)), ...
			true(1, numel(filters{2}.psi.filter))});
	options = fill_struct(options, 'x_resolution', [0; 0]);
	options = fill_struct(options, 'negative_freq', 0);

	filters_ct = [numel(filters{1}.psi.filter)+1 numel(filters{2}.psi.filter)+1];
	p1_phi = numel(filters{1}.psi.filter)+1;

	if options.negative_freq
		neg_filters = flip_filters(filters{1});
		filters_ct(1) = filters_ct(1) + numel(neg_filters.psi.filter);
	end

	N_orig = size(x);
	N_orig = N_orig(1:2);

	N_padded(1) = filters{1}.meta.size_filter/2^options.x_resolution(1);
	N_padded(2) = filters{2}.meta.size_filter/2^options.x_resolution(2);

	x = pad_signal(x, N_padded, 'symm');

	% along 1
	N = size(x,1);

	[temp,psi_bw,phi_bw] = filter_freq(filters{1}.meta);

	j0 = log2(filters{1}.meta.size_filter/N);

	xf = fft(x,[],1);
	xf = reshape(xf,[size(xf,1) size(xf,2)*size(xf,3)]);

	x1 = cell(filters_ct(1), 1);
	res1 = zeros(filters_ct(1) ,1);
	bw1 = zeros(filters_ct(1), 1);
	for p1 = find(options.psi_mask{1})
		ds = round(log2(2*pi/psi_bw(p1)/2)) - ...
		     j0 - ...
		     options.antialiasing;
		ds = max(ds, 0);

		y = conv_sub_1d(xf, filters{1}.psi.filter{p1}, ds);
		y = reshape(y,[size(y,1) size(y,2)/size(x,3) size(x,3)]);
		x1{p1,1} = y;
		res1(p1,1) = ds;
		bw1(p1,1) = psi_bw(p1);

		if options.negative_freq
			y = conv_sub_1d(xf, neg_filters.psi.filter{p1}, ds);
			y = reshape(y,[size(y,1) size(y,2)/size(x,3) size(x,3)]);
			x1{end+1-p1,1} = y;
			res1(end+1-p1,1) = ds;
			bw1(end+1-p1,1) = psi_bw(p1);
		end
	end

	ds = round(log2(2*pi/phi_bw)) - ...
	     j0 - ...
	     options.antialiasing;
	ds = max(ds, 0);

	y = real(conv_sub_1d(xf, filters{1}.phi.filter, ds));
	y = reshape(y,[size(y,1) size(y,2)/size(x,3) size(x,3)]);
	x1{p1_phi,1} = y;
	res1(p1_phi,1) = ds;
	bw1(p1_phi,1) = phi_bw;

	% along 2
	N = size(x,2);

	[temp,psi_bw,phi_bw] = filter_freq(filters{2}.meta);

	j0 = log2(filters{2}.meta.size_filter/N);

	x2 = cell(filters_ct);
	res2 = zeros(1, filters_ct(2));
	bw2 = zeros(1, filters_ct(2));
	meta.j1 = -1*ones([1 filters_ct]);
	meta.j2 = -1*ones([1 filters_ct]);
	meta.bandwidth = -1*ones([2 filters_ct]);
	meta.resolution = -1*ones([2 filters_ct]);
	for p1 = 1:size(x1,1)
		if isempty(x1{p1})
			continue;
		end

		xf = fft(x1{p1},[],2);
		xf = permute(xf,[2 1 3]);
		xf = reshape(xf,[size(xf,1) size(xf,2)*size(xf,3)]);

		for p2 = find(options.psi_mask{2})
			ds = round(log2(2*pi/psi_bw(p2)/2)) - ...
			     j0 - ...
			     options.antialiasing;
			ds = max(ds, 0);

			y = conv_sub_1d(xf, filters{2}.psi.filter{p2}, ds);
			y = reshape(y,[size(y,1) size(y,2)/size(x,3) size(x,3)]);
			y = permute(y,[2 1 3]);
			x2{p1,p2} = y;
			res2(1,p2) = ds;
			bw2(1,p2) = psi_bw(p2);
			x2{p1,p2} = unpad_signal(x2{p1,p2}, [res1(p1) res2(p2)], N_orig);
			meta.j1(:,p1,p2) = p1-1;
			meta.j2(:,p1,p2) = p2-1;
			meta.bandwidth(:,p1,p2) = [bw1(p1) bw2(p2)];
			meta.resolution(:,p1,p2) = [res1(p1) res2(p2)];
		end

		ds = round(log2(2*pi/phi_bw)) - ...
		     j0 - ...
		     options.antialiasing;
		ds = max(ds, 0);

		y = real(conv_sub_1d(xf, filters{2}.phi.filter, ds));
		y = reshape(y,[size(y,1) size(y,2)/size(x,3) size(x,3)]);
		y = permute(y,[2 1 3]);
		x2{p1,end} = y;
		res2(1,end) = ds;
		bw2(1,end) = phi_bw;
		x2{p1,end} = unpad_signal(x2{p1,end}, [res1(p1) res2(end)], N_orig);
		meta.j1(:,p1,end) = p1-1;
		meta.j2(:,p1,end) = filters_ct(2)-1;
		meta.bandwidth(:,p1,end) = [bw1(p1) bw2(end)];
		meta.resolution(:,p1,end) = [res1(p1) res2(end)];
	end

	x_phi = x2{p1_phi,end};
	x2{p1_phi,end} = [];
	x_psi = x2;

	meta_phi.j1 = meta.j1(:,p1_phi,end);
	meta_phi.j2 = meta.j2(:,p1_phi,end);
	meta_phi.bandwidth = meta.bandwidth(:,p1_phi,end);
	meta_phi.resolution = meta.resolution(:,p1_phi,end);

	meta_psi = meta;
	meta_psi.j1(:,p1_phi,end) = [0];
	meta_psi.j2(:,p1_phi,end) = [0];
	meta_psi.bandwidth(:,p1_phi,end) = [0; 0];
	meta_psi.resolution(:,p1_phi,end) = [0; 0];
end

