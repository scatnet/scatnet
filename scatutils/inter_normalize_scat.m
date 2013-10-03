function S=inter_normalize(S,Sn,layerNb,epsilon)
%This function creates a normalization of the first order coefficients of S
%by the elements of the 'zero' order coefficients of Sn

m=layerNb;

if nargin < 4
    epsilon = 2^(-20);		% ~1e-6
end

if m==1
    
    for p2 = 1:length(S{2}.signal)
        sub_multiplier = 2^(S{2}.meta.resolution(p2)/2);
        
        %whatever happens, Sn{1}.signal{1} will always be at a lower or equal
        %resolution than S{2}.signal{p2}
        
        ds = log2(size(Sn{1}.signal{1},1)/size(S{2}.signal{p2},1));
        if ds > 0
            parent = Sn{1}.signal{1}(1:2^ds:end,:,:)*2^(ds/2);
        else
            parent = interpft(Sn{1}.signal{1},size(Sn{1}.signal{1},1)*2^(-ds))*2^(-ds/2);
        end
        
        S{2}.signal{p2} = S{2}.signal{p2}./(parent+epsilon*sub_multiplier);
    end
    
elseif m==2
    
    for p2 = 1:length(S{m+1}.signal)
        j = S{m+1}.meta.j(:,p2);
        p1 = find(all(bsxfun(@eq,S{m}.meta.j,j(1:m-1)),1));
        sub_multiplier = 2^(S{m+1}.meta.resolution(p2)/2);
        ds = log2(size(Sn{m}.signal{p1},1)/size(S{m+1}.signal{p2},1));
        if ds > 0
            parent = Sn{m}.signal{p1}(1:2^ds:end,:,:)*2^(ds/2);
        else
            parent = interpft(Sn{m}.signal{p1},size(Sn{m}.signal{p1},1)*2^(-ds))*2^(-ds/2);
        end
        S{m+1}.signal{p2} = S{m+1}.signal{p2}./(parent+epsilon*sub_multiplier);
    end
    
else
    error('this value of m is not handled yet!')
end  
end
