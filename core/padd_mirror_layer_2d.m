function layer_padded = padd_mirror_layer_2d(layer, margin)
layer_padded.signal = ...
  cellfun(@(x)(padd_mirror(x, margin)), layer.signal, 'UniformOutput', 0);
layer_padded.meta = layer.meta;
end