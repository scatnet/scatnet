function dual_filters = dual_filter_bank(filters)
	A = littlewood_paley(filters);
	
	dual_filters = filters;
	
	for k = 1:length(filters.psi.filter)
		old_psi = realize_filter(filters.psi.filter{k});
		new_psi = conj(old_psi)./A;
		opt.filter_format = 'fourier';
		if isstruct(filters.psi.filter{k})
			opt.filter_format = filters.psi.filter{k}.type;
		end
		dual_filters.psi.filter{k} = optimize_filter(new_psi, 0, opt);
	end
	
	old_phi = realize_filter(filters.phi.filter);
	new_phi = conj(old_phi)./A;
	opt.filter_type = 'fourier';
	if isstruct(filters.phi.filter)
		opt.filter_format = filters.phi.filter.type;
	end
	dual_filters.phi.filter = optimize_filter(new_phi, 1, opt);
end