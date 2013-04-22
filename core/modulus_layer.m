function U = modulus_layer(W)
	U.signal = cellfun(@abs, W.signal, 'UniformOutput', 0);
	U.meta = W.meta;
end