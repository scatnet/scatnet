function Y = max_scat(X,N)
	for m = 0:length(X)-1
		Y{m+1}.signal = {};
		% initialize target meta with same fields as source
		Y{m+1}.meta = struct();
		field_names = fieldnames(X{m+1}.meta);
		for k = 1:length(field_names)
			Y{m+1}.meta = setfield(Y{m+1}.meta,field_names{k}, ...
				zeros(size(getfield(X{m+1}.meta,field_names{k}),1),0));
		end
		r1 = 1;
		for p1 = 1:length(X{m+1}.signal)
			signal = X{m+1}.signal{p1};
			% determine the window size at the current resolution
			N1 = N/2^(X{m+1}.meta.resolution(p1));
			% copy metas of this signal into metas of multiple signals
			Y{m+1}.meta = map_meta(X{m+1}.meta,p1,Y{m+1}.meta,p1);
			% extract set of frames of length N1
			signal = reshape(signal,[N1 size(signal,1)/N1 size(signal,2)]);
			signal = permute(signal,[2 3 1]);
			signal = max(signal,[],3);
			Y{m+1}.signal{p1} = signal(:,:);
		end
	end
end
