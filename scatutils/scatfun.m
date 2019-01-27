% SCATFUN Apply function to all scattering layers
%
% Usage
%    Sx_out = SCATFUN(fun, Sx)
%
% Input
%    fun (function handle): A function handle acting on an individual signal in
%       a layer.
%    Sx (cell array): A scattering transform obtained from SCAT or a similar
%       function.
%
% Output
%    Sx_out (cell array): The same scattering transform, but with fun applied
%       to each signal in each layer.

function Sx_out = scatfun(fun, Sx)
    for m = 1:numel(Sx)
       Sx_out{m} = scatfun_layer(fun, Sx{m});
    end
end

function layer_out = scatfun_layer(fun, layer)
    layer_out = layer;
    for p = 1:numel(layer.signal)
       layer_out.signal{p} = fun(layer.signal{p});
    end
end
