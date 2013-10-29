function [T, Tu] = sec_order_reshape(S)

% Second order coefficients
S2 = S{3};

T=[];
for i=1:size(S2.signal,2)
T(S2.meta.j(1,i)+1, S2.meta.j(2,i)+1) = S2.signal{i};
end


limi1=size(T,1)-1;
limi2=limi1;
Tu=zeros(1,size(T,2)-1);
weights=Tu;
for j=1:min(limi1,size(T,1))
for n=j+1:min(limi2,size(T,2))
pes = 2^(-j);
Tu(n-j) = Tu(n-j) + pes*T(j,n);
weights(n-j) = weights(n-j) + pes;
end
end
I=find(weights>0);
Tu=Tu(I);
weights=weights(I);
Tu=Tu./weights;


