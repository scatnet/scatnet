% realize_filter: Provides a Fourier representation of a filter.
% Usage
%    filter_f = realize_filter(filter, N)
% Input
%    filter: The filter structure, usually from filters{m}.psi.filter{k} or 
%       filters{m}.phi.filter.
%    N (optional): The signal size for which the filters should be defined
%       (default the maximum size allowed by the filter).
% Output
%    filter_f: The Fourier transform of the filter for signal size N.

function filter_f = realize_filter(filter, N)
	if nargin < 2
		N = [];
	end
	
	if isnumeric(filter)
		filter_f = filter;
	elseif strcmp(filter.type,'fourier_multires')
		filter_f = filter.coefft{1};
	elseif strcmp(filter.type,'fourier_truncated')	
		N0 = filter.N;
		
		filter_f = zeros(N0,1);
		
		if filter.start <= 0
			ind = [N0+filter.start:N0 1:length(filter.coefft)+filter.start-1];
		else
			ind = [1:length(filter.coefft)]+filter.start-1;
		end
		
		filter_f(ind) = filter.coefft;
	end
	
	if ~isempty(N)
		if length(N) == 1
			j0 = log2(size(filter_f)./[N 1]);
		else
			j0 = log2(size(filter_f)./N);
		end
	else
		j0 = [0 0];
	end
	filter_f = filter_f(1:2^j0(1):end,1:2^j0(2):end);
end