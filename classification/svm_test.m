% svm_test: Calculate labels for an SVM model.
% Usage
%    [labels, votes, feature_labels] = svm_test(db, model, prt_test)
% Input
%    db: The database containing the feature vector.
%    model: The affine space model obtained from svm_train.
%    prt_test: The object indices of the testing instances.
% Output
%    labels: The assigned labels.
%    votes: The number of votes for each testing instance and class pair.
%    feature_labels: The labels assigned to the individual features.

function [labels,votes,feature_labels,K,sv_coef,dec] = svm_test(db,model,prt_test)
	ind_features = [db.indices{prt_test}];
	
	if ~model.full_test_kernel && ...
		(model.svm.Parameters(2) == 4 || ...
		model.svm.Parameters(2) == 5 || ...
		model.svm.Parameters(2) == 6 || ...
		model.svm.Parameters(2) == 7)
		[kernel_mask,kernel_ind] = ismember(1:size(db.features,2),db.kernel.kernel_set);
	
		ind_features = ind_features(kernel_mask(ind_features));
	end

	[feature_labels,temp,K,sv_coef,dec] = svm_feature_test(db,model.svm,ind_features,model.full_test_kernel);
		
	for l = 1:length(prt_test)
		ind = find(ismember(ind_features,db.indices{prt_test(l)}));
		
		votes(:,l) = histc(feature_labels(ind),1:length(db.src.classes));
		
		[temp,labels(l)] = max(votes(:,l));
	end
end

function [labels,votes,K,sv_coef,dec] = svm_feature_test(db,model,ind_features0,full_test_kernel)
	block_size = 8192;

	class_ct = model.nr_class;
	
	sv_coef = zeros(model.totalSV,class_ct*(class_ct-1)/2,class(db.features));
	
	pairs = [];
	
	r = 1;
	for n1 = 1:class_ct
		for n2 = n1+1:class_ct
			pairs = [pairs [n1; n2]];
			
			class1_SVs = 1+sum(model.nSV(1:n1-1)):sum(model.nSV(1:n1));
			class2_SVs = 1+sum(model.nSV(1:n2-1)):sum(model.nSV(1:n2));
			
			sv_coef(class1_SVs,r) = model.sv_coef(class1_SVs,n2-1);
			sv_coef(class2_SVs,r) = model.sv_coef(class2_SVs,n1);
			r = r+1;
		end
	end

	dec = zeros(length(ind_features0),size(sv_coef,2),class(db.features));

	if full_test_kernel && ...
		(model.Parameters(2) == 4 || ...
		 model.Parameters(2) == 5 || ...
		 model.Parameters(2) == 6 || ...
		 model.Parameters(2) == 7)
		norm2 = sum(abs(db.features(:,db.kernel.kernel_set(model.SVs))).^2,1);
	end

	n = 1;
	while n <= length(ind_features0)
		mask = n:min(n+block_size-1,length(ind_features0));
		ind_features = ind_features0(mask);
		
		if model.Parameters(2) == 0			% linear kernel
			K = db.features(:,ind_features).'*model.SVs.';
		elseif model.Parameters(2) == 2		% Gaussian kernel
			norm1 = sum(abs(db.features(:,ind_features)).^2,1);
			norm2 = sum(abs(model.SVs.').^2,1);
			K = bsxfun(@plus,norm1.',norm2)-... 
				2*db.features(:,ind_features).'*model.SVs.';
			K = exp(-model.Parameters(4)*K);
		elseif full_test_kernel && ...
			(model.Parameters(2) == 4 || ...
			 model.Parameters(2) == 5 || ...
			 model.Parameters(2) == 6 || ...
			 model.Parameters(2) == 7)
		
			if strcmp(db.kernel.kernel_type,'linear')
				K = db.features(:,ind_features).'*db.features(:,db.kernel.kernel_set(model.SVs));
			elseif strcmp(db.kernel.kernel_type,'gaussian')
				norm1 = sum(abs(db.features(:,ind_features)).^2,1);
				%norm2 = sum(abs(db.features(:,db.kernel.kernel_set(model.SVs))).^2,1);
				K = bsxfun(@plus,norm1.',norm2)-... 
					2*db.features(:,ind_features).'*db.features(:,db.kernel.kernel_set(model.SVs));
			else
				error('unknown kernel type');
			end
		elseif model.Parameters(2) == 4	|| ...
			   model.Parameters(2) == 6 % Precalculated kernel (in db.kernel)
			[kernel_mask,kernel_ind] = ismember(1:size(db.features,2),db.kernel.kernel_set);
			K = db.kernel.K(1+model.SVs,kernel_ind(ind_features)).';
		elseif model.Parameters(2) == 5 || ...
			   model.Parameters(2) == 7
			K = zeros(length(ind_features),length(model.SVs),class(db.kernel.K));
			
			[kernel_mask,kernel_ind] = ismember(1:size(db.features,2),db.kernel.kernel_set);
		
			for k = 1:length(ind_features)
				idx = kernel_ind(ind_features(k));
				
				% Need to cast to integers since floating-point indexing causes
				% problems. Take 64 bits to be safe...
				lower_SVs = int64(model.SVs(model.SVs<=idx));
				upper_SVs = int64(model.SVs(model.SVs>idx));
				
				K(k,model.SVs<=idx) = ...
					db.kernel.K((idx-1)*(idx-1+3)/2+1+lower_SVs);
				K(k,model.SVs>idx) = ...
					db.kernel.K((upper_SVs-1).*(upper_SVs-1+3)/2+1+idx);
			end
		end
		
		if (model.Parameters(2) == 4 && strcmp(db.kernel.kernel_type,'gaussian')) || ...
		   model.Parameters(2) == 6 || model.Parameters(2) == 7
			K = exp(-model.Parameters(4)*K);
		end

		dec(mask,:) = bsxfun(@minus,K*sv_coef,model.rho.');
	
		n = n+length(mask);
	end

	votes = zeros(size(dec,1),class_ct);
	
	for r = 1:size(pairs,2)
		n1 = pairs(1,r);
		n2 = pairs(2,r);
		
		votes(dec(:,r)>=0,n1) = votes(dec(:,r)>=0,n1)+1;
		votes(dec(:,r)<0,n2) = votes(dec(:,r)<0,n2)+1;
	end
	
	[temp,labels] = max(votes,[],2);
	
	labels = model.Label(labels);
end
