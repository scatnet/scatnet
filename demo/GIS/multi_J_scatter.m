function mScatt=multi_J_scatter(sig,fparam,options,Jmax)
%Compute the scattering vector for all the J such that 1<=J<=Jmax. Note
%that no values of J has been defined in fparam (no fparam.J) and that the
%filters used with these functions will most of the time be cubic spline
%wavelets.

N=length(sig);
cascades=cell(Jmax,1);

for k=1:Jmax
    fparam.J=k;
    cascades{k} = cascade_factory_1d(N, fparam,options, fparam.J);
end

mScatt=zeros(Jmax+1,2*N);
mScatt(1,1:N)=sig;


for p=2:Jmax+1
   
    tScatt=reorder_scat(scat(sig,cascades{p-1}));
  
  mScatt(p,:)=tScatt;
end