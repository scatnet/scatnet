% RENORM_1ST Renormalize first-order coefficients by local L1 norm (central)
%
% Usage
%    S = renorm_1stc(S, x, Wop)
%
% Input
%    S: A scattering transform.
%    x: The original signal.
%    Wop: The wavelet operator used to define the averaging of the absolute
%        value signal.
%
% Output
%    S: The scattering transform with first-order coefficients divided by
%       the absolute value of x averaged by Wop at the center of the window.

function [S,S1] = renorm_1stc(S, x, Wop, epsilon, replace)
	if nargin < 4
		epsilon = 2^(-20); 
	end

	if nargin < 5
		replace = 0;
	end

	U0.signal{1} = abs(x);
	U0.meta.j = zeros(0,1);
	U0.meta.resolution = 0;
	S1 = Wop(U0);
	S1 = resample_scat(S1, S{2}.meta.resolution(1));
	sub_multiplier = 2^(S{2}.meta.resolution(1)/2);
	mid = round(size(S1.signal{1},1)/2);
	S{2}.signal = cellfun(@(x)(bsxfun(@times,x,1./(S1.signal{1}(mid,:,:,:)+epsilon*sub_multiplier))), S{2}.signal, ...
		'UniformOutput',0);

	if replace
		S{1} = S1;
	end
end
