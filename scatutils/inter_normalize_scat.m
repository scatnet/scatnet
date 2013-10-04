function V_end = inter_normalize_scat(V,Vn,layerNb,epsilon)
% V can be either the scattering transform V or U. 
%This function creates a normalization of the first order coefficients of V
%by the elements of the 'zero' order coefficients of Vn

m=layerNb;

if nargin < 4
    epsilon = 2^(-20);		% ~1e-6
end

if m==1
    
    for p2 = 1:length(V{2}.signal)
        sub_multiplier = 2^(V{2}.meta.resolution(p2)/2);
        
        %whatever happens, Vn{1}.signal{1} will always be at a lower or equal
        %resolution than V{2}.signal{p2}
        
        ds = log2(size(Vn{1}.signal{1},1)/size(V{2}.signal{p2},1));
        if ds > 0
            parent = Vn{1}.signal{1}(1:2^ds:end,:,:)*2^(ds/2);
        else
            parent = interpft(Vn{1}.signal{1},size(Vn{1}.signal{1},1)*2^(-ds))*2^(-ds/2);
        end
        
        V{2}.signal{p2} = V{2}.signal{p2}./(parent+epsilon*sub_multiplier);
    end
    
elseif m==2
    
    for p2 = 1:length(V{m+1}.signal)
        j = V{m+1}.meta.j(:,p2);
        p1 = find(all(bsxfun(@eq,V{m}.meta.j,j(1:m-1)),1));
        sub_multiplier = 2^(V{m+1}.meta.resolution(p2)/2);
        ds = log2(size(Vn{m}.signal{p1},1)/size(V{m+1}.signal{p2},1));
        if ds > 0
            parent = Vn{m}.signal{p1}(1:2^ds:end,:,:)*2^(ds/2);
        else
            parent = interpft(Vn{m}.signal{p1},size(Vn{m}.signal{p1},1)*2^(-ds))*2^(-ds/2);
        end
        V{m+1}.signal{p2} = V{m+1}.signal{p2}./(parent+epsilon*sub_multiplier);
    end
    
else
    error('this value of m is not handled yet!')
end  
end
