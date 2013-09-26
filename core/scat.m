% SCAT Compute the scattering transform
%
% Usage
%    [S, U] = SCAT(x, Wop) 
%
% Input
%    x (numeric): The input signal.
%    Wop (cell of function handles): Linear operators used to generate a new 
%       layer from the previous one.
%
% Output
%    S (cell): The scattering coefficients.
%    U (cell): Intermediate covariant modulus coefficients.
%
% Description
%    The signal x is decomposed using linear operators Wop and modulus 
%    operators, creating scattering invariants S and intermediate covariant
%    coefficients U. 
%
%    Each element of the Wop array is a function handle of the signature
%       [A, V] = Wop{m+1}(U),
%    where m ranges from 0 to M (M being the order of the transform). The 
%    outputs A and V are the invariant and covariant parts of the operator.
%
%    The variables A, V and U are all of the same structure, that of a network
%    layer. Specifically, the have one field, signal, which is a cell array
%    corresponding to the constituent signals, and another field, meta, which
%    contains various information on these signals.
%
%    The scattering transform therefore initializes the first layer of U using
%    the input signal x, then iterates on the following transformation
%       [S{m+1}, V] = Wop{m+1}(U{m+1});
%       U{m+2} = modulus_layer(V);
%    The invariant part of the linear operator is therefore output as a scat-
%    tering coefficient, and the modulus covariant part V is assigned to the 
%    next layer of U.
%
% See also : WAVELET_FACTORY_1D, WAVELET_FACTORY_2D, 
%   WAVELET_FACTORY_2D_PYRAMID,

function [S, U] = scat(x, Wop)
	% Initialize signal and meta
	U{1}.signal{1} = x;
	U{1}.meta.j = zeros(0,1);
	U{1}.meta.q = zeros(0,1);
    U{1}.meta.resolution=0;

	% Apply scattering, order per order
	for m = 0:numel(Wop)-1
		if (m < numel(Wop)-1)
			[S{m+1}, V] = Wop{m+1}(U{m+1});
			U{m+2} = modulus_layer(V);
		else
			S{m+1} = Wop{m+1}(U{m+1});
		end
	end
end
