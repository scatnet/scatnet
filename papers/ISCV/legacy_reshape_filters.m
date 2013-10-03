function [psi,phi,lp]=legacy_reshape_filters(filters,sizein)

J=max(filters.psi.meta.j)+1;
L=max(filters.psi.meta.theta);

r=1;
for j=1:J
for l=1:L
tmp = filters.psi.filter{r}.coefft{1};
tmp = fftshift(ifft2(tmp));
tmp = fftshift(cropc(tmp,sizein));
psi{j}{l} = fft2(tmp);
r=r+1;
end
end
tmp=filters.phi.filter.coefft{1};
tmp = fftshift(ifft2(tmp));
tmp = fftshift(cropc(tmp,sizein));
phi = fft2(tmp);

tempo.psi{1}=psi;
tempo.phi{1}=phi;
lp=littlewood_paley_ISCV(tempo);

end


function out=cropc(in,sizein)

[M1,M2]=size(in);

out=in(M1/2-sizein(1)/2+1:M1/2+sizein(1)/2, M2/2-sizein(2)/2+1:M2/2+sizein(2)/2);

end
