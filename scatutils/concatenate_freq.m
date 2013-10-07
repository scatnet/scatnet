function Y = concatenate_freq(X, fmt)
	if nargin < 2
		fmt = 'table';
	end
	
	if iscell(X)
		% We have a complete transform - a cell array of layers - so apply it
		% to each layer.
		Y = {};
	
		for m = 0:length(X)-1
			Y{m+1} = concatenate_freq(X{m+1}, fmt);
		end
		
		return;
	end
	
	% Form equivalences between coefficients with the same j1 and group them
	% together
	if isfield(X.meta,'fr_j')
		% We have scattering along frequency, use this to group
		[temp1,temp2,assigned] = unique([X.meta.fr_j; X.meta.j(2:end,:)].','rows');
	else
		[temp1,temp2,assigned] = unique(X.meta.j(2:end,:).','rows');
	end
	
	% Prepare output and intialize meta structure.
	Y.signal = {};
	Y.meta = struct();
	field_names = fieldnames(X.meta);
	for n = 1:length(field_names)
		sz = size(getfield(X.meta,field_names{n}));
		Y.meta = setfield(Y.meta,field_names{n},zeros(sz(1),0));
	end
	
	% 1D coefficients are of the form Nx1xK, where N is the number of time
	% samples and K is the number of signals. Permute them so we have NxKx1,
	% instead, this simplifies creating tables later.
	X.signal = cellfun(@(x)(permute(x,[1 3 2])), X.signal, ...
		'UniformOutput', false);
	
	for k = 1:max(assigned)
		sz_orig = size(X.signal{1});
		
		% Select the coefficients belonging to the current group.
		ind = find(assigned==k);
		
		if strcmp(fmt,'table')
			% Each 'signal' being a table of size NxK, as described above, and
			% the cell array being arranged horizontally, the following con-
			% catenates all the signals of indices ind into a table of size
			% Nx(KP), where P is the number of coefficients in the current 
			% group.
			nsignal = [X.signal{ind}];
			
			% Unwrap the second dimension to have NxKxP
			nsignal = reshape(nsignal,[size(nsignal,1) sz_orig(2) length(ind)]);
			% Put the frequency in the first dimension and the signal index 
			% in the last dimension, giving PxNxK.
			nsignal = permute(nsignal,[3 1 2]);
		else
			% Don't make a table, just copy the cell array. Note that this is 
			% not very compatible with the normal layer structure.
			nsignal = X.signal(ind);
		end
		
		% Store the kth table in the output signal
		Y.signal{k} = nsignal;
		
		% Copy the relevant meta fields from input to output. Note that the 
		% pth column of the meta fields no longer corresponds to the pth 
		% coefficient in Y.signal{p}. Instead, the cumulative index along the
		% second dimension is used. As such, if there are P different lambda1s
		% in Y.signal{1}, so P = size(Y.signal{1},2), the first P columns of
		% meta correspond to these signals.
		for n = 1:length(field_names)
			src_value = getfield(X.meta,field_names{n});
			dst_value = getfield(Y.meta,field_names{n});
			dst_value = [dst_value src_value(:,ind)];
			Y.meta = setfield(Y.meta,field_names{n},dst_value);
		end
	end
end
