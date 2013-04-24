function [x_phi, x_psi] = wavelet_1d(x, filters, options)
	if nargin < 3
		options = struct();
	end

	options = fill_struct(options, 'antialiasing', 1);
	options = fill_struct(options, ...
		'psi_mask', {true(1, numel(filters{1}.psi.filter)), ...
			true(1, numel(filters{2}.psi.filter))});
	
	% along 1
	N = size(x,1);

	[temp,psi_bw,phi_bw] = filter_freq(filters{1});

	j0 = log2(filters{1}.N/N);

	xf = fft(x,[],1);
	
	x1 = cell(numel(filters{1}.psi.filter)+1,1);
	for p1 = find(options.psi_mask{1})
		ds = round(log2(2*pi/psi_bw(p1)/2)) - ...
		     j0 - ...
		     options.antialiasing;
		ds = max(ds, 0);
	
		x1{p1,1} = conv_sub_1d(xf, filters{1}.psi.filter{p1}, ds);
	end
	
	ds = round(log2(2*pi/phi_bw)) - ...
	     j0 - ...
	     options.antialiasing;
	ds = max(ds, 0);

	x1{end,1} = real(conv_sub_1d(xf, filters{1}.phi.filter, ds));
	
	% along 2
	N = size(x,2);

	[temp,psi_bw,phi_bw] = filter_freq(filters{2});

	j0 = log2(filters{2}.N/N);

	x2 = cell(numel(filters{1}.psi.filter)+1,numel(filters{2}.psi.filter)+1);

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
		end

		ds = round(log2(2*pi/phi_bw)) - ...
		     j0 - ...
		     options.antialiasing;
		ds = max(ds, 0);

		x2{p1,end} = permute(real(conv_sub_1d(permute(xf,[2 1 3]), filters{2}.phi.filter, ds)),[2 1 3]);
	end
	
	x_phi = x2{end,end};
	x2{end,end} = [];
	x_psi = x2;
end
