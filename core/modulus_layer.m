% MODULUS_LAYER Calculate the modulus of coefficients in a layer
%
% Usage
%    U = MODULUS_LAYER(W)
%
% Input
%    W (struct): A scattering layer, as output by WAVELET_LAYER_*, for exam-
%       ple.
%
% Output
%    U (struct): The same layer with all coefficients set to their absolute
%       values.
%
% See Also
%    PAD_SIGNAL, UNPAD_SIGNAL

function U = modulus_layer(W)
	U.signal = cellfun(@abs, W.signal, 'UniformOutput', 0);
	U.meta = W.meta;
end