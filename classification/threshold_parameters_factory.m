function [sigma1,sigma2]= threshold_parameters_factory(feature_fun,src,sigma_fun,options)

db=prepare_sigma_database(src,feature_fun,options);

sigma1=zeros(length(db{1}),1);
%sigma2=zeros(length(db{2}),1);

if strcmp(sigma_fun,'median')==1
   parfor k=1:length(db{1})
    sigma1(k) = median(db{1}{k},1);
   end

   parfor k=1:length(db{2})
    sigma2(k) = median(db{2}{k},1);
   end
sigma1=(1/0.6745).*median(db1.features(meta.order==1,:),2);
sigma2=(1/0.6745).*median(db1.features(meta.order==2,:),2);

elseif strcmp(sigma_fun,'stdev')==1
    
   parfor k=1:length(db{1})
    sigma1(k) =std(db{1}{k},[],1);
   end

   parfor k=1:length(db{2})
    sigma2(k) = std(db{2}{k},[],1);
   end
   
else
    error('sigma_fun not supported yet!')
end

save([path 'sigmas_sDbf_T12_Q11.mat'],'sigma1','sigma2');

end
