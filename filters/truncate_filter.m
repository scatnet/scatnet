function filter = truncate_filter(filter_f, threshold, lowpass)
	N = length(filter_f);
	
	filter.type = 'fourier_truncated';
	filter.N = N;

	% Could have filter.recenter = lowpass, but since we don't know if we're
	% taking the modulus or not, we always need to recenter.
	filter.recenter = 1;
	
	[temp,ind_max] = max(filter_f);
	filter_f = circshift(filter_f,N/2-ind_max);
	ind1 = find(abs(filter_f)>(max(abs(filter_f))*threshold),1);
	ind2 = find(abs(filter_f)>(max(abs(filter_f))*threshold),1,'last');
	
	len = ind2-ind1+1;
	len = filter.N/2^(floor(log2(filter.N/len)));
	
	ind1 = round(round((ind1+ind2)/2)-len/2);
	ind2 = ind1+len-1;
	
	filter_f = filter_f(mod([ind1:ind2]-1,filter.N)+1);
	
	filter.coefft = filter_f;
	filter.start = ind1-(N/2-ind_max);
end
