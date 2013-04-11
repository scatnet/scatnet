function filter = periodize_filter(filter_f,threshold)
	N = length(filter_f);
	
	filter.type = 'fourier_multires';
	filter.N = N;
	
	filter.coefft = {};
	
	j0 = 0;
	while 1
		if abs(floor(N/2^j0)-N/2^j0)>1e-6
			break;
		end
		
		filter.coefft{j0+1} = sum(reshape(filter_f,[N/2^j0 2^j0]),2);
		
		j0 = j0+1;
	end
end
