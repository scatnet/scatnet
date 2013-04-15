function Y = flatten_scatt(X,depth)
	Y.signal = {};
	Y.meta = struct();
	
	Y.meta.order = [];
	
	meta_fields = fieldnames(X{1}.meta);
	
	r = 1;
	for m = 0:length(X)-1
		ind = r:r+length(X{m+1}.signal)-1;
		
		Y.signal(ind) = X{m+1}.signal;
		
		for k = 1:length(meta_fields)
			field = meta_fields{k};
			
			if isfield(Y.meta,field)
				value = getfield(Y.meta,field);
			else
				value = [];
			end
			new_value = getfield(X{m+1}.meta,field);
			
			if size(value,2) < size(new_value,2)
				value = [value ...
					-ones(size(value,1),size(new_value,2)-size(value,2))];
			elseif size(value,2) > size(new_value,2)
				new_value = [new_value ...
				 	-ones(size(new_value,1),size(value,2)-size(new_value,2))];
			end
			
			value = [value; new_value];
			
			Y.meta = setfield(Y.meta,field,value);
		end
		
		Y.meta.order = [Y.meta.order; m*ones(length(ind),1)];
		
		r = r+length(ind);
	end
end