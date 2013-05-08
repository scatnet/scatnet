% flatten_scatt: Put scattering coefficients of all layers together
% Usage
%    S = flatten_scatt(S)
% Input
%    S: A scattering transform.
% Output
%    S: The same scattering transform, but flattened into one layer. As a 
%       result, meta fields that have different number of rows are set to
%       


function Y = flatten_scatt(X)
	Y.signal = {};
	Y.meta = struct();
	
	Y.meta.order = [];
	
	meta_fields = fieldnames(X{1}.meta);
	
	r = 1;
	for m = 0:length(X)-1
		ind = r:r+length(X{m+1}.signal)-1;
		
		Y.signal(ind) = X{m+1}.signal;
		
		for p = 1:length(meta_fields)
			field = meta_fields{p};
			
			if isfield(Y.meta,field)
				value = getfield(Y.meta,field);
			else
				value = [];
			end
			new_value = getfield(X{m+1}.meta,field);
			
			if size(value,1) < size(new_value,1)
				value = [value; ...
					-ones(size(new_value,1)-size(value,1),size(value,2))];
			elseif size(value,1) > size(new_value,1)
				new_value = [new_value; ...
				 	-ones(size(value,1)-size(new_value,1),size(new_value,2))];
			end
			
			value = [value new_value];
			
			Y.meta = setfield(Y.meta,field,value);
		end
		
		Y.meta.order = [Y.meta.order m*ones(1,length(ind))];
		
		r = r+length(ind);
	end
	
	Y = {Y};
end