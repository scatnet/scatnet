function [U_phi, U_psi] = joint_wavelet_layer_1d(U, filters, options)
	if nargin < 3
		options = struct();
	end
	
	calc_U = (nargout>=2);
	
	options = fill_struct(options,'time_renormalize',0);
	options = fill_struct(options,'time_renormalize_epsilon',2^(-20));
	
	if ~isfield(U.meta, 'bandwidth'), U.meta.bandwidth = 2*pi; end
	if ~isfield(U.meta, 'resolution'), U.meta.resolution = 0; end

	% renormalize in time
	% un-normalized coefficients are in U, normalized coefficients are in Up
	
	if calc_U && options.time_renormalize
		Up = concatenate_freq(U,'cell');
		r0 = 1;
		for k = 1:length(Up.signal)
			ind0 = r0:r0+length(Up.signal{k})-1;
		
			resolutions = unique(Up.meta.resolution(ind0));
		
			for l = 1:length(resolutions)
				valid = find(Up.meta.resolution(ind0)<=resolutions(l));
				% WARNING: this is wrong, should try to use correct N
				% will only work if the original signal is of size N, not smaller
				mask = 1:2^resolutions(l):filters{2}.N/2;
				if resolutions(l)<max(resolutions)
					mask = mask(2:2:end);
				end
				nsignal = zeros(length(valid),length(mask));
				for r = 1:length(valid)
					res1 = Up.meta.resolution(ind0(valid(r)));
					mask1 = ((mask-1)/2^res1+1);
					nsignal(r,:) = Up.signal{k}{valid(r)}(mask1)/sqrt(2^res1);
				end
				options1 = options;
				options1.x_resolution = 0; % WARNING: wrong!
				options1.psi_mask = [];
				options1.phi_renormalize = 0;
				options1.antialiasing = 100;
				nsignal_phi = wavelet_1d(nsignal, filters{1}, options1);
				nsignal = nsignal./(nsignal_phi+options.time_renormalize_epsilon);
				for r = 1:length(valid)
					res1 = Up.meta.resolution(ind0(valid(r)));
					mask1 = ((mask-1)/2^res1+1);
					Up.signal{k}{valid(r)}(mask1) = nsignal(r,:)*sqrt(2^res1);
				end
			end
		
			r0 = r0+length(Up.signal{k});
		end
		Up = separate_freq(Up);
	end
	
	% filter along time, no modulus

	% Compute convolutions along time (filters{2} contains temporal filters).
	if calc_U
		[U_phi, U_psi] = wavelet_layer_1d(U, filters{2}, options);
		if options.time_renormalize
			% If we have renormalized coefficents, decompose them too.
			[Up_phi, Up_psi] = wavelet_layer_1d(Up, filters{2}, options);
		else
			Up_phi = U_phi;
			Up_psi = U_psi;
		end
	else
		% No U to calculate, jsut the lowpass then.
		U_phi = wavelet_layer_1d(U, filters{2}, options);
		U_psi.signal = {};
		U_psi.meta = struct();
		U_psi.meta.j = zeros(0,0);
		
		Up_phi = U_phi;
		Up_psi = U_psi;
	end
	
	% Line the coefficients up into time-frequency tables
	Y_phi = concatenate_freq(U_phi);
	Y_psi = concatenate_freq(U_psi);
	Yp_phi = concatenate_freq(Up_phi);
	Yp_psi = concatenate_freq(Up_psi);
	
	% Prepare fr_j fields if they are not present.
	if ~isfield(Y_phi.meta,'fr_j')
		Y_phi.meta.fr_j = zeros(0,size(Y_phi.meta.j,2));
	end
	
	if ~isfield(Y_psi.meta,'fr_j')
		Y_psi.meta.fr_j = zeros(0,size(Y_psi.meta.j,2));
	end
	
	if ~isfield(Yp_phi.meta,'fr_j')
		Yp_phi.meta.fr_j = zeros(0,size(Yp_phi.meta.j,2));
	end
	
	if ~isfield(Yp_psi.meta,'fr_j')
		Yp_psi.meta.fr_j = zeros(0,size(Yp_psi.meta.j,2));
	end
	
	% These U_psi and U_psi are going to contain the real outputs, filtered in frequency as well.
	U_phi.signal = {};
	U_phi.meta = struct();
	
	U_psi.signal = {};
	U_psi.meta = struct();
	U_psi.meta.fr_j = zeros(size(Y_phi.meta.fr_j,1)+1,0);
	U_psi.meta.j = zeros(size(Y_phi.meta.j,1)+1,0);

	% Set up indices for U_phi and U_psi.
	r_phi = 1;
	r_psi = 1;
	p2 = 1;
	for s = 1:4
		% Process each of the tables.
		if s == 1
			Z = Y_phi;
		elseif s == 2
			Z = Y_psi;
		elseif s == 3
			Z = Yp_phi;
		elseif s == 4
			Z = Yp_psi;
		end
		
		% If field is not present, there has been no subsampling along frequency so set it to zero.
		if ~isfield(Z.meta,'fr_resolution')
			Z.meta.fr_resolution = zeros(1,size(Z.meta.j,2));
		end
		
		r0 = 1;
		
		for p1 = 1:length(Z.signal)
			% For each table (there may be multiple if we're on 2nd order)..
			
			% TODO: Actually use fr_bw to calc psi_mask etc.
			if s <= 2
				% On un-normalized coefficients, just calculate lowpass.
				psi_mask = false(size(filters{1}.psi.filter));
			else
				% On normalized coefficients, calculate them all.
				psi_mask = calc_U&true(size(filters{1}.psi.filter));
			end
		
			% Specify options for frequency decomposition.
			options1 = options;
			options1.x_resolution = Z.meta.fr_resolution(p1);
			options1.psi_mask = psi_mask;
			options1.phi_renormalize = 0;

			% Get the current table and reshape it. Since we only want to 
			% transform along columns, we need to interleave these with 
			% the signal index (third), so that each column is transformed
			% independently.
			signal = Z.signal{p1};
			sz_orig = size(signal);
			sz_orig = [sz_orig ones(1,3-length(sz_orig))];
			signal = reshape(signal,[sz_orig(1) 1 sz_orig(2)*sz_orig(3)]);

			% Actually transform using frequency filters (filters{1}).
			[Z_phi, Z_psi, meta_phi, meta_psi] = ...
				wavelet_1d(signal, filters{1}, options1);
			
			if s == 1
				% We've transformed the (un-normalized) temporal low-pass Y_phi,
				% so we only care about the frequential lowpass Z_phi.
				
				% Determine the subsampling rate along frequency.
				ds = meta_phi.resolution;
				% Extract the indices of the "original" signal along frequency,
				% with subsampling by 2^ds.
				ind0 = r0:2^ds:r0+size(signal,1)-1;
				% How many frequency indices are left?
				fr_count = size(Z_phi,1);
				% Put everything back into "table x signal idx" format & copy.
				% Note that there is a 1-to-1 correspondence between Z (Y_phi)
				% and U_phi, so p1 will do perfectly as an index.
				U_phi.signal{p1} = reshape(Z_phi,[size(Z_phi,1) sz_orig(2:3)]);
				% Determine the indices in the U_phi output array.
				ind_phi = r_phi:r_phi+fr_count-1;
		
				% Copy the meta fields of the original frequencies.
				U_phi.meta = map_meta(Z.meta,ind0,U_phi.meta,ind_phi);
				% Assign the frequential resolution after subsampling by 2^ds.
				U_phi.meta.fr_resolution(1,ind_phi) = ds*ones(1,fr_count);
				
				% Increase current running U_phi index.
				r_phi = r_phi+length(ind_phi);
			elseif s == 2
				% We've transformed the (un-normalized) temporal band-pass 
				% Y_psi, so we care about both both frequential low-pass and
				% band-pass Z_phi and Z_psi, respectively.
				
				% To facilitate treatment, just handle the low-pass as another
				% band-pass filter and concatenate to Z_psi.
				Z_psi = [Z_psi Z_phi];
				psi_mask = [psi_mask true];
				meta_psi = map_meta(meta_phi,1,meta_psi,length(Z_psi));
			end
			% Note that if s == 3 or s == 4, we don't include the low-pass
			% components Z_phi, only Z_psi. This is because for these 
			% normalized coefficients, we only want band-pass x band-pass.
		
			for k = find(psi_mask)
				% For each frequential band-pass filter.
				
				% Put everything back into "table x signal idx" format & copy.
				% Note that we need to keep track of p2 here and increase it
				% afterwards.
				U_psi.signal{p2} = reshape(Z_psi{k},[size(Z_psi{k},1) sz_orig(2:3)]);
				% Determine the subsampling rate along frequency.
				ds = meta_psi.resolution(k);
				% Extract the indices of the "original" signal along frequency,
				% with subsampling by 2^ds.
				ind0 = r0:2^ds:r0+size(signal,1)-1;
				% How many frequency indices are left?
				fr_count = size(Z_psi{k},1);
				% Determine the indices in the U_phi output array.
				ind_psi = r_psi:r_psi+fr_count-1;
				% Copy the meta fields of the original frequencies.
				U_psi.meta = map_meta(Z.meta,ind0,U_psi.meta,ind_psi,{'j','fr_j'});
				
				if s == 2 || s == 4
					% If we're a temporal band-pass Y_psi or Yp_psi, new j's
					% are just old j's.
					U_psi.meta.j(:,ind_psi) = Z.meta.j(:,ind0);
				else
					% If we're a temporal low-pass Y_phi or Yp_phi, new j's
					% are big J. This won't already be in Z.meta.j since
					% low-pass filter indices are not in there.
					U_psi.meta.j(:,ind_psi) = [Z.meta.j(:,ind0); length(filters{2}.psi.filter)*ones(1,fr_count)];
				end
				% Add the latest frequency decomposition scale, fr_j, which
				% here is given by the loop index k, minus one.
				U_psi.meta.fr_j(:,ind_psi) = [Z.meta.fr_j(:,ind0); (k-1)*ones(1,fr_count)];
				% Assign the frequential resolution after subsampling by 2^ds.
				U_psi.meta.fr_resolution(1,ind_psi) = ds*ones(1,fr_count);
				
				% Increase the current running U_psi index.
				r_psi = r_psi+length(ind_psi);
				% Increase the path index p2.
				p2 = p2+1;
			end
			
			% Increase the current running Z index.
			r0 = r0+size(signal,1);
		end
	end

	% Transform our tables into "frequency channels" like before.
	U_phi = separate_freq(U_phi);
	U_psi = separate_freq(U_psi);
end

%%% TODO
% - incorporate progressivity along frequency
