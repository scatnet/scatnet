% TRUNCATE_FILTER Truncates the Fourier transform of a filter
%
% Usage
%    filter = TRUNCATE_FILTER(filter_f, threshold, lowpass)
%
% Input
%    filter_f (numeric): The Fourier representation of the filter.
%
% Output
%    filter (struct): The truncated representation of the filter. See descrip-
%       tion for more details.
%
% Description
%    By extracting and storing only the Fourier transform coefficients whose 
%    are above a certain threshold relative to the maximum value, storage
%    requirements for the filters are lessened and computation is sped up
%    since only non-zero coefficients are multiplied during convolution.
%
%    The support of the Fourier transform is defined so that all coefficients
%    with a magnitude above threshold*fmax are kept, where fmax is the maxi-
%    mum magnitude, and so that length(filter_f) divided by the size of the
%    support is a power of 2.
%
%    The output filter contains the fields:
%       filter.type (char): Fixed to 'fourier_truncated'.
%       filter.N (int): The original size of the filter.
%       filter.recenter (boolean): Indicates whether the Fourier transform
%          should be recentered after convolution. This is always true.
%       filter.start (int): The frequency index where the support of the
%          Fourier transform starts.
%       filter.coefft (numeric): The values of the Fourier coefficients on the
%          support.
%
% See also 
%    OPTIMIZE_FILTER, PERIODIZE_FILTER

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
