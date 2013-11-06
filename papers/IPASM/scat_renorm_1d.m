function [S,T,Tu,ex] = scat_renorm_1d(process, param ,options, R)


firstref=getoptions(options,'firstref',1);
J=options.J;

scatcoeffs= J + J*(J-1)/2;
ave1=zeros(scatcoeffs,2);
for t=1:R
X=process(param);
[Sr]=scat(X,options.Wop);
ave1=update_avg_coeffs(ave1,Sr);
fprintf('%d .. ',t)
end
fprintf('\n')
[~,Sr] = update_avg_coeffs(ave1/R, Sr);
ex=X;

Sr = renorm_scat(Sr);

S = first_order_reshape(Sr,firstref);
[T, Tu] = sec_order_reshape(Sr);



