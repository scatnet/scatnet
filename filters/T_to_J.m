%TODO redo doc
%T_TO_J Calculates the maximal wavelet scale for a filter bank
%   J = T_to_J(T,Q,a) calculates the closest integer J corresponding to T
%   gives Q, a such that T = Q*a^J. By default a = 2^(1/Q) if Q is specified,
%   otherwise Q = 1, a = 2.

function J = T_to_J(T, Q, B, phi_bw_multiplier)
	if nargin < 2 || isempty(Q)
		Q = 1;
	end
	
	if nargin < 3 || isempty(B)
		B = Q;
	end
	
	if nargin < 4 || isempty(phi_bw_multiplier)
		phi_bw_multiplier = 1+(Q==1);
	end
	
	J = round(log2(T./(2*B./phi_bw_multiplier)).*Q);
end