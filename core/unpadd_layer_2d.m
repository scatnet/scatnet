function layer_unpadded = unpadd_layer_2d(layer, size_padded_original, margin_out)
	layer_unpadded.signal = cellfun(@(x)(unpadd(x, size_padded_original, margin_out)), ...
		layer.signal, 'UniformOutput', 0);
	layer_unpadded.meta = layer.meta;
end
