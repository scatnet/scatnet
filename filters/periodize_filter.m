% PERIODIZE_FILTER Periodizes filter at multiple resolutions
%
% Usage
%    filter = PERIODIZE_FILTER(filter_f)
%
% Input
%    filter_f (numeric): The Fourier representation of the filter.
%
% Output
%    filter (struct): The periodized multi-resolution representation of the 
%       filter. See description for more details.
%
% Description
%    By periodizing the Fourier transform, which corresponds to subsampling in
%    time, representations of the filter at different resolutions are
%    pre-computed, computation is sped during convolutions.
%
%    The output filter contains the fields:
%       filter.type (char): Fixed to 'fourier_multires'.
%       filter.N (int): The original size of the filter.
%       filter.coefft (cell): A cell array Fourier representations, with
%          filter.coefft{j0+1} corresponding to the resolution N/2^j0.
%
% See also 
%    OPTIMIZE_FILTER, TRUNCATE_FILTER

function filter = periodize_filter(filter_f)
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
