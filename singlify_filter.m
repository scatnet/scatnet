function filter = singlify_filter(filter)
	if (iscell(filter.coefft))
		for res = 1:numel(filter.coefft)
			filter.coefft{res}  = single(filter.coefft{res});
		end
	else
		filter.coefft = single(filter.coefft);
	end
	
end