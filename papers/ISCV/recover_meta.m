function meta=recover_meta(in, dirac)

%meta.order
%meta.scale
%meta.orientation
%meta.dirac_norm
%meta.ave

J=in{1}.meta.j;
L=max(in{2}.meta.theta);

meta.order(1)=1;
meta.scale(1)=-1;
meta.orientation(1)=0;
meta.dirac_norm(1)=norm(dirac{1}.signal{1}(:));
meta.ave(1)=mean(in{1}.signal{1}(:));
r=2;
for m=2:size(in,2)
for l=1:size(in{m}.signal,2)
meta.order(r)=m;
meta.scale(r)=simplestack(in{m}.meta.j(1:end-1,l),J,m-1);
meta.orientation(r)=simplestack(in{m}.meta.theta(:,l)-1,L,m-1);
meta.dirac_norm(r)=norm(dirac{m}.signal{l}(:));
meta.ave(r)=mean(in{m}.signal{l}(:));
r=r+1;
end
end

end


function out=simplestack(code, base, len)
out=0;
for l=1:len
out=base*out+code(l);
end

end



