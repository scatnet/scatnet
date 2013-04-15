function [labels,err,feature_err] = affine_test(db,model,prt_test)
	test_mask = ismember(1:length(db.src.objects),prt_test);
	
	ind_obj = find(test_mask);
	
	ind_feat = [db.indices{ind_obj}];
	
	[feature_labels,feature_err] = select_class(...
		db.features(:,ind_feat),model.mu,model.v,model.dim);
		
	err = zeros(...
		[size(feature_err,1),length(ind_obj),size(feature_err,3)]);
	labels = zeros(size(feature_err,1),length(ind_obj));
		
	for l = 1:length(ind_obj)
		ind = find(ismember(ind_feat,db.indices{ind_obj(l)}));
		
		err(:,l,:) = mean(feature_err(:,ind,:),2);
		
		[temp,labels(:,l)] = min(err(:,l,:),[],3);
	end
end

function [d,err] = select_class(t,mu,v,dim)
	L = length(dim);	% number of dimensions
	D = length(mu);		% number of classes
	P = size(t,2);		% number of feature vectors

	err = Inf*ones(max(dim)+1,P,D);
	for d = 1:D
		if isempty(mu{d})
			continue;
		end
		err(1:size(v{d},2)+1,:,d) = approx(t,mu{d},v{d});
	end
	
	err = err(dim+1,:,:);
	
	[temp,d] = min(err,[],3);
end

function err = approx(s,mu,v)
	s = bsxfun(@minus,s,mu);
	
	err = zeros(size(v,2)+1,size(s,2));
	
	err(1,:) = sum(abs(s).^2,1);
	err(2:end,:) = -abs(v'*s).^2;
	
	err = sqrt(cumsum(err,1));
end