
function sigmas=threshold_parameters_factory(db,meta,sigma_fun)

% THRESHOLD_PARAMETERS_FACTORY: compute the standard_deviation of each path
% in the database.


nb_j1=max(meta.j(1,:));
sigma1=zeros(1,nb_j1+1);
size(sigma1)

sigma2=[];

for j1=0:nb_j1
    
    ind1=find(meta.order==1 & meta.j(1,:)==j1);
    %obj_feats=db.features(:,db.indices{objs})
    in_cols=db.features(ind1,:);
    if strcmp(sigma_fun,'median')==1
         in_cols=in_cols';
        sigma1(j1+1)= (1/0.6745)*median(in_cols(:));
    elseif strcmp(sigma_fun,'std')==1
        sigma1(j1+1)=std(in_cols(:));
    else
        error('sigma_fun not yet supported')
    end
    
    for j2=j1+1:nb_j1
        ind2=find(meta.order==2 & meta.j(1,:)==j1 & meta.j(2,:)==j2);
        %obj_feats=db.features(:,db.indices{objs})
        ind2tot{j1+1}{j2+1}=ind2;
        in_cols2=db.features(ind2,:);
        if ~isempty(in_cols2)
            
            if strcmp(sigma_fun,'median')==1
                in_cols2=in_cols2';
                sigma2=[sigma2 (1/0.6745)*median(in_cols2(:))];
            elseif strcmp(sigma_fun,'std')==1
                sigma2=[sigma2 std(in_cols2(:))];
            else
                error('sigma_fun not yet supported')
            end
        end
    end
    
end   

sigmas={sigma1,sigma2};

end

