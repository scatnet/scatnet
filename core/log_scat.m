% log_scat: Calculate the logarithm of a scattering transform.
% Usage
%    S = log_scat(S)
% Input
%    S: A scattering transform.
% Output
%    S: The scattering transform with the logarithm applied to each 
%       coefficient.

function X = log_scat(X,epsilon)
	if nargin < 2
		epsilon = 2^(-20);		% ~1e-6
	end
	
	for m = length(X)-1:-1:0
		for p1 = 1:length(X{m+1}.signal)
			sub_multiplier = 2^(X{m+1}.meta.resolution(p1)/2);
			X{m+1}.signal{p1} = log(abs(X{m+1}.signal{p1})+epsilon*sub_multiplier);
		end
	end
end