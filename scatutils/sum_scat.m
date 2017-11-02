% SUM_SCAT Average all frames of a scattering transform
%
% Usage
%    S = SUM_SCAT(S);
%
% Input
%    S (cell): A scattering transform.
%
% Output
%    S (cell): The scattering transform with each signal is averaged over the
%       length of the signal.
%
% See also 
%    AGGREGATE_SCAT, FLATTEN_SCAT

function X = sum_scat(X)
	for m = length(X)-1:-1:0
		for p1 = 1:length(X{m+1}.signal)
            X{m+1}.signal{p1} = mean(X{m+1}.signal{p1}, 1);
		end
	end
end
