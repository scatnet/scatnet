function Y = concatenate_freq(X,fmt)
	if nargin < 2
		fmt = 'table';
	end
	
	if iscell(X)
		Y = {};
	
		for m = 0:length(X)-1
			Y{m+1} = concatenate_freq(X{m+1},fmt);
		end
		
		return;
	end
	
	if isfield(X.meta,'fr_j')
		[temp1,temp2,assigned] = unique([X.meta.fr_j; X.meta.j(2:end,:)].','rows');
	else
		[temp1,temp2,assigned] = unique(X.meta.j(2:end,:).','rows');
	end
	
	Y.signal = {};
	Y.meta = struct();
	field_names = fieldnames(X.meta);
	for n = 1:length(field_names)
		sz = size(getfield(X.meta,field_names{n}));
		Y.meta = setfield(Y.meta,field_names{n},zeros(sz(1),0));
	end
	
	X.signal = cellfun(@(x)(permute(x,[1 3 2])), X.signal, ...
		'UniformOutput', false);
	
	for k = 1:max(assigned)
		sz_orig = size(X.signal{1});
		
		ind = find(assigned==k);
		
		if strcmp(fmt,'table')
			nsignal = [X.signal{ind}];
			
			% need to extract the signal index dimension (2nd here)
			nsignal = reshape(nsignal,[size(nsignal,1) sz_orig(2) length(ind)]);
			nsignal = permute(nsignal,[3 1 2]);
		else
			nsignal = X.signal(ind);
		end
		
		Y.signal{k} = nsignal;
		
		for n = 1:length(field_names)
			src_value = getfield(X.meta,field_names{n});
			dst_value = getfield(Y.meta,field_names{n});
			dst_value = [dst_value src_value(:,ind)];
			Y.meta = setfield(Y.meta,field_names{n},dst_value);
		end
	end
end
