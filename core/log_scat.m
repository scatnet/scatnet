% log_scat: Calculate the logarithm of a scattering transform.
% Usage
%    S = log_scat(S)
% Input
%    S: A scattering transform.
% Output
%    S: The scattering transform with the logarithm applied to each 
%       coefficient.

function S = log_scat(S, epsilon)
	if nargin < 2
		epsilon = 2^(-20);		% ~1e-6
	end

	if iscell(X)
		for m = 0:length(S)-1
			S{m+1} = log_scat(S{m+1}, epsilon);
		end
	
		return;
	end
	
	for p1 = 1:length(S.signal)
		sub_multiplier = 2^(S.meta.resolution(p1)/2);
		S.signal{p1} = log(abs(S.signal{p1})+epsilon*sub_multiplier);
	end
end