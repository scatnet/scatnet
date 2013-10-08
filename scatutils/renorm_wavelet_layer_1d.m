
function [A,V_end] = renorm_wavelet_layer_1d(A_and_V,epsilon)

if nargin < 3
    epsilon = 2^(-20);		% ~1e-6
end

A=A_and_V{1};
V=A_and_V{2};
V_end=V;

for m=2:length(V)
    for p2 = 1:length(V{m}.signal)
    j = V{m}.meta.j(:,p2);
    p1 = find(all(bsxfun(@eq,V{m}.meta.j,j(1:m-1)),1));
    sub_multiplier = 2^(V{m}.meta.resolution(p2)/2);
    ds = log2(size(A{m}.signal{p1},1)/size(V{m}.signal{p2},1));
    if ds > 0
        parent = A{m}.signal{p1}(1:2^ds:end,:,:)*2^(ds/2);
    else
        parent = interpft(A{m}.signal{p1},size(A{m}.signal{p1},1)*2^(-ds))*2^(-ds/2);
    end
    V_end.signal{p2} = V.signal{p2}./(parent+epsilon*sub_multiplier);
    end

     
end

end