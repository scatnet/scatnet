function filter = periodize_filter(filter_f,threshold)
	N = size(filter_f);
	N = N(N>1);
	
	filter.type = 'fourier_multires';
	filter.N = N;
	
	filter.coefft = {};
	
	j0 = 0;
	while 1
		if any(abs(floor(N./2^j0)-N./2^j0)>1e-6)
			break;
		end
		
		if length(N) == 1
			sz_in = [N/2^j0 2^j0 1 1];
			sz_out = [N/2^j0 1];
		else
			sz_in = [N(1)/2^j0 2^j0 N(2)/2^j0 2^j0];
			sz_out = N./2^j0;
		end
		
		filter.coefft{j0+1} = reshape( ...
			sum(sum(reshape(filter_f,sz_in),2),4),sz_out);
		
		j0 = j0+1;
	end
end
