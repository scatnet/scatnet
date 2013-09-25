function filters = singlify_filter_bank(filters)
	filters.phi.filter = singlify_filter(filters.phi.filter);
	
	for p = 1:numel(filters.psi.filter)
		filters.psi.filter{p} = singlify_filter(filters.psi.filter{p});
	end
end
