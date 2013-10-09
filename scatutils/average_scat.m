% AVERAGE_SCAT Average successive frames of a scattering transform
%
% Usage
%    S = AVERAGE_SCAT(S, T, step, window_fun)
%
% Input
%    S (cell): A scattering transform.
%    T (int): The length of the window with which to average.
%    step (int, optional): The stepping of the successive windows (default 
%        T/2).
%    window_fun (function handle, optional): The windowing function to use for
%        averaging (default @hanning_standalone).
%
% Output
%    S (cell): The scattering transform with each signal averaged over a 
%       window of length N using the window function specified.
%
% See also 
%    AGGREGATE_SCAT, FLATTEN_SCAT

function X = average_scat(X, T, step, window_fun)
	if nargin < 3
		step = T/2;
	end

	if nargin < 4
		window_fun = @hanning_standalone;
	end

	for m = length(X)-1:-1:0
		for p1 = 1:length(X{m+1}.signal)
			if ~isfield(X{m+1}.meta,'resolution')
				res = 0;
			else
				res = X{m+1}.meta.resolution(p1);
			end
			N0 = size(X{m+1}.signal{p1},1);


			if T < 2^res
				continue;
			end
			% calculate the T and step at current resolution
			real_T = T/2^res;
			real_step = max(1,step/2^res);
			% calculate number of windows we get & allocate buffer
			n_windows = floor(size(X{m+1}.signal{p1},1)/real_step);
			buf = zeros([real_T,n_windows,size(X{m+1}.signal{p1},3)]);
			% since we want symmetric boundary conditions, we need to extend
			% the signal symmetrically
			ind0 = [1:N0 N0:-1:1];
			% cut out the relevant segments & place in buffer
			for k = 1:n_windows
				center = (k-1)*real_step+1;
				% for a given center & T, calculate the corresponding indices
				ind = ind0(mod(floor([center-real_T/2+1:center+real_T/2])-1,2*N0)+1);

				buf(:,k,:) = X{m+1}.signal{p1}(ind,:,:);

			end
			% for each segment, multiply by windowing kernel & sum
			kernel = window_fun(size(buf,1));
			buf = bsxfun(@times,buf,kernel/sum(kernel));
			buf = sum(buf,1);

			% get rid of dimension 1 & store result in X
			buf =permute(buf,[2 1 3]);

			X{m+1}.signal{p1} = buf;
			X{m+1}.meta.resolution(p1) = res+log2(real_step);
		end
	end
end
