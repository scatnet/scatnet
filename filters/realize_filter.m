function filter_f = realize_filter(filter)
	if isnumeric(filter)
		filter_f = filter;
	elseif strcmp(filter.type,'fourier_multires')
		filter_f = filter.coefft{1};
	elseif strcmp(filter.type,'fourier_truncated')
		N = filter.N;
		
		filter_f = zeros(N,1);
		
		if filter.start <= 0
			ind = [N+filter.start:N 1:length(filter.coefft)+filter.start-1];
		else
			ind = [1:length(filter.coefft)]+filter.start-1;
		end
		
		filter_f(ind) = filter.coefft;
	end
end