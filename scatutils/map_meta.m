% MAP_META Copy meta fields
%
% Usage
%    to_meta = MAP_META(from_meta, from_ind, to_meta, to_ind, except)
%
% Input
%    from_meta (struct): The meta structure to copy from.
%    from_ind (int): The range of columns to copy from.
%    to_meta (struct): The meta struture to copy to.
%    to_ind (int): The range of columns to copy to.
%
% Output
%    to_meta (struct): The meta structure with the fields copied.
%
% Description
%    The columns specified by from_ind in the from_meta struture are copied
%    into the columns specified by to_ind in the to_meta structure. If from_ind
%    only contains one index, these values are replicated across all columns
%    given in to_ind.


function to_meta = map_meta(from_meta, from_ind, to_meta, to_ind, except)
	if nargin < 5
		except = {};
	end
	
	field_names = fieldnames(from_meta);
	
	fact = length(to_ind)/length(from_ind);
	if abs(fact-round(fact))>1e-6
		error('length(to_ind) must be a multiple of length(from_ind)');
	end
	
	for k = 1:length(field_names)
		if any(strcmp(field_names{k},except))
			continue;
		end
		from_value = getfield(from_meta,field_names{k});
		if isfield(to_meta,field_names{k})
			to_value = getfield(to_meta,field_names{k});
		else
			to_value = zeros(size(from_value,1),0);
		end
		%if all(size(to_value)==[0 0])
		%	to_value = zeros(0,length(from_ind));
		%else
			to_value(:,to_ind) = repmat(from_value(:,from_ind), ...
				[1 length(to_ind)/length(from_ind)]);
		%end
		to_meta = setfield(to_meta,field_names{k},to_value);
	end
end
