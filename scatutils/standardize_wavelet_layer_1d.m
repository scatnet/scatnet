function [A_white,V_white]=standardize_wavelet_layer_1d(A_and_V,sigmas,epsilon)

if nargin <4
    epsilon = 2^(-20);
end

A_white =A_and_V{1};

V=A_and_V{2};
V_white=V;

if nargin < 2
    warning('no sigma provided so V remains unchanged!');
else
    for f=1:length(V.signal)
        if sigmas(f)==0
        V_white.signal{f}=V.signal{f}./epsilon;
        else V_white.signal{f}=V.signal{f}./sigmas(f);
        end
    end
end
end

