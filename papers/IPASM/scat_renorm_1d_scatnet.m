function [S,T,Tu,ex] = scat_renorm_1d_scatnet(process, param ,options, R)


firstref=getoptions(options,'firstref',1);
J=options.J;

scatcoeffs= J + J*(J-1)/2;
ave1=zeros(scatcoeffs,2);
for t=1:R
X=process(param);

% --------- SCATTERING WITH SCATNET FILTER BANKS ----------
[S,U]=scat(X,options.Wop);
% --------- AVERAGE OVER U SIGNALS TO GET Sr FROM JOAN'S VERSION --------
Sr = U;
for i=1:3
    for j=1:length(Sr{i}.signal)
        Sr{i}.signal{j} = 2^(-Sr{i}.meta.resolution(j)/2)*mean(Sr{i}.signal{j});
    end
end
% --------------------------------------------------------------

ave1=update_avg_coeffs(ave1,Sr);
fprintf('%d .. ',t)
end
fprintf('\n')
[~,Sr] = update_avg_coeffs(ave1/R, Sr);
ex=X;

Sr = renorm_scat(Sr);

S = first_order_reshape(Sr,firstref);
[T, Tu] = sec_order_reshape(Sr);
end
