% REALIZE_FILTER Provides a Fourier representation of a filter
%
% Usage
%    filter_f = REALIZE_FILTER(filter, N)
%
% Input
%    filter (struct): The filter structure, usually from 
%       filters{m}.psi.filter{k} or filters{m}.phi.filter.
%    N (int, optional): The signal resolution for which the filters should be 
%       defined (default the maximum size allowed by the filter).
%
% Output
%    filter_f (numeric): The Fourier transform of the filter for signal size 
%       N.
%
% See also
%    OPTIMIZE_FILTER, PERIODIZE_FILTER, TRUNCATE_FILTER

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
		elseif filter.start+length(filter.coefft) > N0
			ind = [filter.start:N0 1:length(filter.coefft)+filter.start-N0-1];
		else
			ind = [1:length(filter.coefft)]+filter.start-1;
		end
		
		filter_f(ind) = filter.coefft;
	end
		
	if ~isempty(N)
		filter_f = [filter_f(1:N(1)/2,:); ...
			filter_f(N(1)/2+1,:)/2+filter_f(end-N(1)/2+1,:)/2; ...
			filter_f(end-N(1)/2+2:end,:)];
		if length(N) > 1 && N(2) ~= 1
			filter_f = [filter_f(:,1:N(2)/2) ...
				filter_f(:,N(2)/2+1)/2+filter_f(:,end-N(2)/2+1)/2 ...
				filter_f(:,end-N(2)/2+2:end)];
		end
	end
end