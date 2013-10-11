
function [A,Utilde] = renorm_low_pass_layer_1d(A, U, epsilon)
    
    if nargin < 3
        epsilon = 1e-6;		% ~1e-6
    end
    
    Utilde = U;
    
    for p = 1:length(U.signal)
        sub_multiplier = 2^(U.meta.resolution(p)/2); 
        denom = interpft(A.signal{p},size(U.signal{p},1));
        Utilde.signal{p} = U.signal{p} ./ (denom + epsilon*sub_multiplier);
    end
    
end