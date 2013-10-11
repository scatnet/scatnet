
function sigmas=threshold_parameters_factory(db,meta,sigma_fun)

% THRESHOLD_PARAMETERS_FACTORY: compute the standard_deviation of each path
% in the database.

m=max(meta.order);
sigmas=cell(1,m);

%%sigmas will be of size at least one and most often of size 2.

nb_j1=max(meta.j(1,:));
sigmas{1}=zeros(1,nb_j1+1);

if m == 2
    sigmas{2}=[];
end

for j1=0:nb_j1
    
    ind1=find(meta.order==1 & meta.j(1,:)==j1);
    %obj_feats=db.features(:,db.indices{objs})
    in_cols=db.features(ind1,:);
    if strcmp(sigma_fun,'median')==1
        in_cols=in_cols';
        sigmas{1}(j1+1)= (1/0.6745)*median(in_cols(:));
    elseif strcmp(sigma_fun,'std')==1
        sigmas{1}(j1+1)=std(in_cols(:));
    else
        error('sigma_fun not yet supported')
    end
    
    if m == 2
        
        for j2=0:nb_j1
            ind2=find(meta.order==2 & meta.j(1,:)==j1 & meta.j(2,:)==j2);
            %obj_feats=db.features(:,db.indices{objs})
            %ind2tot{j1+1}{j2+1}=ind2;
            in_cols2=db.features(ind2,:);
            if ~isempty(in_cols2)
                
                if strcmp(sigma_fun,'median')==1
                    in_cols2=in_cols2';
                    sigmas{2}=[sigmas{2} (1/0.6745)*median(in_cols2(:))];
                elseif strcmp(sigma_fun,'std')==1
                    sigmas{2}=[sigmas{2} std(in_cols2(:))];
                else
                    error('sigma_fun not yet supported')
                end
            end
        end
    end
end


end

