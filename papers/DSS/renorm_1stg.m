% RENORM_1ST Renormalize first-order coefficients by global L1 norm
%
% Usage
%    S = renorm_1stg(S, x)
%
% Input
%    S: A scattering transform.
%    x: The original signal.
%
% Output
%    S: The scattering transform with first-order coefficients divided by
%       the average absolute value of x.

function S = renorm_1stg(S, x, epsilon)
	if nargin < 3
		epsilon = 2^(-20); 
	end

	S1 = mean(abs(x),1);
	sub_multiplier = 2^(S{2}.meta.resolution(1)/2);
	S{2}.signal = cellfun(@(x)(bsxfun(@times,x,1./(S1+epsilon*sub_multiplier))), S{2}.signal, ...
		'UniformOutput',0);
end

