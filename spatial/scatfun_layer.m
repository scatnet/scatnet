% scatfun_layer : applies fun to all signal of a ScatNet layer
%
% Usage
%   layer_out = scatfun_layer(fun, layer);
function layer_out = scatfun_layer(fun, layer)
    layer_out = layer;
    for p = 1:numel(layer.signal)
       layer_out.signal{p} = fun(layer.signal{p});
    end
end
