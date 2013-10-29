function out=first_order_reshape(S,ref)

S=S{2};

for j=1:size(S.signal,2)
out(j)= S.signal{j} / S.signal{ref};
end

