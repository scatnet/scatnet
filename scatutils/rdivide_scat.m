function X_end = rdivide_scat(X,Xn,layerNb,epsilon)
%
%
%Usage: 
%
%    X_end = rdivide_scat(X,Xn,layerNb,epsilon)
%
%NOTE:
% Xn will most often be the order one scattering transform of |x| (where
% x is the signal which scattering transform is X)
%
%Input :
% X : the scattering transform S or U whose layer should be normalized.
% Xn: The scattering transform S or U whose layer would be used to
% normalize the one of X
% layerNb: the indice of the layer of Xn to use for normalization
% epsilon: a value fixed to 2^(-20) by default and used to avoid a division
% by zero.
%
% Output: 
% X_end : the scattering transform X whose layer layerNb+1 has been normalized 
%by  the layer layerNb of Xn
%
%
%Description:
%This function normalizes the
% coefficients of the layer m+1 of X by the coefficients of the layer m of Xn
%
% See also
% RENORM_SCAT

m=layerNb;
if m==0
    error('The layer number must be >= to 0');
end

if nargin < 4
    epsilon = 2^(-20);		% ~1e-6
end

X_end=X;

for p2 = 1:length(X{m+1}.signal)
    
    if m==1
        sub_multiplier = 2^(X{2}.meta.resolution(p2)/2);
        ds = log2(size(Xn{1}.signal{1},1)/size(X{2}.signal{p2},1));
        p1=1;
    else
        j = X{m+1}.meta.j(:,p2);
        p1 = find(all(bsxfun(@eq,X{m}.meta.j,j(1:m-1)),1));
        sub_multiplier = 2^(X{m+1}.meta.resolution(p2)/2);
        ds = log2(size(Xn{m}.signal{p1},1)/size(X{m+1}.signal{p2},1));
    end
    
    if ds > 0
        parent = Xn{m}.signal{p1}(1:2^ds:end,:,:)*2^(ds/2);
    else
        parent = interpft(Xn{m}.signal{p1},size(Xn{m}.signal{p1},1)*2^(-ds))*2^(-ds/2);
    end
    X_end{m+1}.signal{p2} = X{m+1}.signal{p2}./(parent+epsilon*sub_multiplier);
end

end
