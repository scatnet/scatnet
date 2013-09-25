% scatfun: applies fun to all signal of a scattering
%
% Usage 
%   Sx_out = scatfun(fun, Sx);
function Sx_out = scatfun(fun, Sx)
    for m = 1:numel(Sx)
       Sx_out{m} = scatfun_layer(fun, Sx{m}); 
    end
end
