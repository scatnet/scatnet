function [A_white, V_white] = standardize_wavelet_layer_1d(A_and_V, sigmas, epsilon)
    if nargin < 2
        error('no sigma provided so V remains unchanged!');
    end
    if nargin <3
        epsilon = 2^(-20);
    end
    
    A_white = A_and_V{1};
    V = A_and_V{2};
    V_white = V;
    
    for p=1:length(V.signal)
        V_white.signal{p} = V.signal{p} ./ (sigmas(p) + epsilon);
    end
    
end

