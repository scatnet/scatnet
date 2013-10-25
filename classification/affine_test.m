% AFFINE_TEST Calculate labels for an affine space model
%
% Usage
%    [labels, err, feature_err] = AFFINE_TEST(db, model, test_set)
%
% Input
%    db (struct): The database containing the feature vector.
%    model (struct): The affine space model obtained from affine_train.
%    test_set (int): The object indices of the testing instances.
%
% Output
%    labels (int): The assigned labels.
%    err (numeric): The average approximation error for each testing instance
%       and class pair.
%    feature_err (numeric): The approximation error for each feature vector 
%       and class pair.
%
% See also
%    AFFINE_TRAIN, AFFINE_PARAM_SEARCH

function [labels,err,feature_err] = affine_test(db,model,test_set)
	% Create mask for the testing vectors.
	test_mask = ismember(1:length(db.src.objects),test_set);
	
	% Get the indices of the testing vectors.
	ind_obj = find(test_mask);
	
	% Determine the feature vector indices.
	ind_feat = [db.indices{ind_obj}];
	
	% Classify the feature vectors separately.
	[feature_labels,feature_err] = select_class(...
		db.features(:,ind_feat),model.mu,model.v,model.dim);
	
	% Prepare a matrix of average appproximation errors for each object (second
	% dimension) with respect to each dimension of the approximating space (first
	% dimension) and class (third dimension)
	err = zeros(...
		[size(feature_err,1),length(ind_obj),size(feature_err,3)]);
	labels = zeros(size(feature_err,1),length(ind_obj));
		
	for l = 1:length(ind_obj)
		% For each object, determine the feature vectors it contains.
		ind = find(ismember(ind_feat,db.indices{ind_obj(l)}));
		
		% Average the approximation error across feature vectors.
		err(:,l,:) = mean(feature_err(:,ind,:),2);
		
		% The label of the object is that of the class with the least error.
		[temp,labels(:,l)] = min(err(:,l,:),[],3);
	end
end

function [d,err] = select_class(t,mu,v,dim)
	L = length(dim);	% number of dimensions
	D = length(mu);		% number of classes
	P = size(t,2);		% number of feature vectors

	% Prepare approximation error vector. First index is the dimension of the
	% approximating affine space, second index that of the feature vectors
	% and third index is that of the approximating class.
	err = Inf*ones(max(dim)+1,P,D);
	for d = 1:D
		if isempty(mu{d})
			% Class has no model, skip.
			continue;
		end
		% Store approximation errors for all feature vectors with class d.
		err(1:size(v{d},2)+1,:,d) = approx(t,mu{d},v{d});
	end
	
	% Only store the approximating dimensions specified in dim.
	err = err(dim+1,:,:);
	
	% Calculate the class of each feature vector as the one minimizing error.
	[temp,d] = min(err,[],3);
end

function err = approx(s,mu,v)
	% Subtract the class centroid.
	s = bsxfun(@minus,s,mu);
	
	% Prepare the error matrix.
	err = zeros(size(v,2)+1,size(s,2));

	% Use Pythagoras to calculate the norm of the orthogonal projection at each
	% approximating dimension.
	err(1,:) = sum(abs(s).^2,1);
	err(2:end,:) = -abs(v'*s).^2;
	err = sqrt(cumsum(err,1));
end
