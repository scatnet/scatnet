function Y = aggregate_scatt(X,N)
	for m = 0:length(X)-1
		Y{m+1}.signal = {};
		Y{m+1}.meta = struct();
		field_names = fieldnames(X{m+1}.meta);
		for k = 1:length(field_names)
			Y{m+1}.meta = setfield(Y{m+1}.meta,field_names{k}, ...
				zeros(size(getfield(X{m+1}.meta,field_names{k}),1),0));
		end
		r1 = 1;
		for p1 = 1:length(X{m+1}.signal)
			%sub_multiplier = 2^(X{m+1}.meta.resolution(p1)/2);
			%X{m+1}.signal{p1} = log(abs(X{m+1}.signal{p1})+epsilon*sub_multiplier);
			signal = X{m+1}.signal{p1};
			N1 = N/2^(X{m+1}.meta.resolution(p1));
			signal = reshape(signal,[N1 size(signal,1)/N1 size(signal,2)]);
			signal = permute(signal,[2 3 1]);
			Y{m+1}.meta = map_meta(X{m+1}.meta,p1,Y{m+1}.meta,r1:r1+N1-1);
			for k1 = 1:N1
				Y{m+1}.signal{r1} = signal(:,:,k1);
				r1 = r1+1;
			end
		end
	end
end

function to_meta = map_meta(from_meta,from_ind,to_meta,to_ind)
	field_names = fieldnames(from_meta);
	
	for k = 1:length(field_names)
		from_value = getfield(from_meta,field_names{k});
		to_value = getfield(to_meta,field_names{k});
		if all(size(to_value)==[0 0])
			to_value = zeros(0,length(from_ind));
		else
			to_value(:,to_ind) = repmat(from_value(:,from_ind),[1 length(to_ind)]);
		end
		to_meta = setfield(to_meta,field_names{k},to_value);
	end
end