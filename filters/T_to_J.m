% T_to_J: Calculates the maximal wavelet scale J from T
% Usage
%    J = T_to_J(T, options)
% Input
%    T: A time interval T.
%    options: A structure containing the parameters of a filter bank.
% Output
%    J: The maximal wavelet scale J such that, for a filter bank created with
%       the parameters in options and this J, the largest wavelet is of band-
%       width approximately T.
% Description
%    J is calculated using the formula T = 4B/phi_bw_multiplier*2^((J-1)/Q), 
%    where B, phi_bw_multiplier and Q are taken from the options structure.

function J = T_to_J(T, Q, B, phi_bw_multiplier)
	if nargin == 2 && isstruct(Q)
		options = Q;
		
		options = fill_struct(options,'Q',1);
		options = fill_struct(options,'B',options.Q);
 		options = fill_struct(options,'phi_bw_multiplier',1+(options.Q==1));
		
		Q = options.Q;
		B = options.B;
		phi_bw_multiplier = options.phi_bw_multiplier;
	else
		if nargin < 2 || isempty(Q)
			Q = 1;
		end
	
		if nargin < 3 || isempty(B)
			B = Q;
		end
	
		if nargin < 4 || isempty(phi_bw_multiplier)
			phi_bw_multiplier = 1+(Q==1);
		end
	end
	
	J = round(log2(T./(4*B./phi_bw_multiplier)).*Q)+1;
end