% SVM_TEST Calculate labels for an SVM model
%
% Usage
%    [labels, votes, feature_labels] = SVM_TEST(db, model, test_set)
%
% Input
%    db (struct): The database containing the feature vector.
%    model (struct): The affine space model obtained from svm_train.
%    test_set (int): The object indices of the testing instances.
%
% Output
%    labels (int): The assigned labels.
%    votes (int): The number of votes for each testing instance and class 
%       pair.
%    feature_labels (int): The labels assigned to the individual features.
%
% See also
%    SVM_TRAIN, CLASSIF_ERR, CLASSIF_RECOG

function [labels,votes,feature_labels,K,sv_coef,dec] = svm_test(db,model,test_set)
	% Determine indices of feature vectors belonging to the test objects.
	ind_features = [db.indices{test_set}];

	if ~model.full_test_kernel && ...
		(model.svm.Parameters(2) == 4 || ...
		model.svm.Parameters(2) == 5 || ...
		model.svm.Parameters(2) == 6 || ...
		model.svm.Parameters(2) == 7)
		% If we're working with a precalculated kernel and only some of the testing
		% vectors are available, only use these (unless full_test_kernel is set).

		[kernel_mask,kernel_ind] = ismember(1:size(db.features,2),db.kernel.kernel_set);
		ind_features = ind_features(kernel_mask(ind_features));
	end

	% Obtain the feature vector labels for ind_features.
	[feature_labels,temp,K,sv_coef,dec] = svm_feature_test(db,model.svm,ind_features,model.full_test_kernel);

	for l = 1:length(test_set)
		% For each object in the test set, count the votes assigned to each of its feature vectors. 

		ind = find(ismember(ind_features,db.indices{test_set(l)}));
		votes(:,l) = histc(feature_labels(ind),1:length(db.src.classes));
		[temp,labels(l)] = max(votes(:,l));
	end
end

function [labels,votes,K,sv_coef,dec] = svm_feature_test(db,model,ind_features0,full_test_kernel)
	% As in SVM_CALC_KERNEL, it's useful to break down kernel computations into
	% blocks.
	block_size = 8192;

	% How many classes are in this model?
	class_ct = model.nr_class;

	% Prepare the matrix of support vector coefficients for each pair of classes,
	% since each corresponds to a different SVM.
	sv_coef = zeros(model.totalSV,class_ct*(class_ct-1)/2,class(db.features));

	pairs = [];

	% Fill the sv_coef matrix. For more details on the model.sv_coef matrix, see
	% the LIBSVM FAQ. The difference with our sv_coefs is that our stores the 
	% coefficients for each class pair, with zeros for the vectors belonging to
	% neither class.
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

	% Prepare matrix of decision values for each testing vector and class pair.
	dec = zeros(length(ind_features0),size(sv_coef,2),class(db.features));

	if full_test_kernel && ...
		(model.Parameters(2) == 4 || ...
		model.Parameters(2) == 5 || ...
		model.Parameters(2) == 6 || ...
		model.Parameters(2) == 7)
		% If we have to recalculate kernel, prepare square norms. This should only
		% be necessary in Gaussian kernel case, though (6 & 7)...
		norm2 = sum(abs(db.features(:,db.kernel.kernel_set(model.SVs))).^2,1);
	end

	n = 1;
	while n <= length(ind_features0)
		% Only deal with testing vectors block by block.
		mask = n:min(n+block_size-1,length(ind_features0));
		ind_features = ind_features0(mask);

		if model.Parameters(2) == 0			% linear kernel
			% Linear kernel was calculated in LIBSVM; recalculate it here.
			K = db.features(:,ind_features).'*model.SVs.';
		elseif model.Parameters(2) == 2		% Gaussian kernel
			% Gaussian kernel was calculated in LIBSVM; recalculate it here.
			norm1 = sum(abs(db.features(:,ind_features)).^2,1);
			model.SVs=full(model.SVs);
			norm2 = sum(abs(model.SVs.').^2,1);
			norm2=full(norm2);
			K = bsxfun(@plus,norm1.',norm2)-...
				2*db.features(:,ind_features).'*model.SVs.';
			K = exp(-model.Parameters(4)*K);
		elseif full_test_kernel && ...
			(model.Parameters(2) == 4 || ...
			model.Parameters(2) == 5 || ...
			model.Parameters(2) == 6 || ...
			model.Parameters(2) == 7)
			% Kernel was precalculated, but for testing, we have to recalculate it. This
			% can be necessary if the set of kernel vectors is restricted.

			if strcmp(db.kernel.kernel_type,'linear')
				% Calculate the linear kernel of the testing vector with respect to the 
				% support vectors.
				K = db.features(:,ind_features).'*db.features(:,db.kernel.kernel_set(model.SVs));
			elseif strcmp(db.kernel.kernel_type,'gaussian')
				% Same for Gaussian kernel, except that we don't multiply by gamma and 
				% exponentiate here. This is done later, as in the precalculated case.
				norm1 = sum(abs(db.features(:,ind_features)).^2,1);
				K = bsxfun(@plus,norm1.',norm2)-...
					2*db.features(:,ind_features).'*db.features(:,db.kernel.kernel_set(model.SVs));
			else
				error('unknown kernel type');
			end
		elseif model.Parameters(2) == 4	|| ...
			model.Parameters(2) == 6
			% Precalculated kernel in square format, so just extract the rows corre-
			% sponding to the support vectors and the columns corresponding to the
			% testing vectors.
			
			% Translate to the kernel indexation.
			[kernel_mask,kernel_ind] = ismember(1:size(db.features,2),db.kernel.kernel_set);
			K = db.kernel.K(1+model.SVs,kernel_ind(ind_features)).';
		elseif model.Parameters(2) == 5 || ...
			model.Parameters(2) == 7
			% Precalculated kernel in triangular format. Need to unpack the kernel for
			% desired support vectors and testing vectors.

			% Prepare the kernel matrix.
			K = zeros(length(ind_features),length(model.SVs),class(db.kernel.K));

			% Obtain kernel indexation.
			[kernel_mask,kernel_ind] = ismember(1:size(db.features,2),db.kernel.kernel_set);

			for k = 1:length(ind_features)
				% For each of the testing vectors, extract the indices in the triangular
				% kernel.

				% Translate to the kernel indexation.
				idx = kernel_ind(ind_features(k));

				% Separate support vectors into those with index below testing vector index
				% and those above. Need to cast to integers since floating-point indexing
				% causes problems. Take 64 bits to be safe...
				lower_SVs = int64(model.SVs(model.SVs<=idx));
				upper_SVs = int64(model.SVs(model.SVs>idx));
		
				% Lower SVs are obtained from the SV rows in the idx column.
				K(k,model.SVs<=idx) = ...
					db.kernel.K((idx-1)*(idx-1+3)/2+1+lower_SVs);
				% Upper SVs are obtained from the idx row in the SV columns.
				K(k,model.SVs>idx) = ...
					db.kernel.K((upper_SVs-1).*(upper_SVs-1+3)/2+1+idx);
			end
		end

		if (model.Parameters(2) == 4 && strcmp(db.kernel.kernel_type,'gaussian')) || ...
			model.Parameters(2) == 6 || model.Parameters(2) == 7
			% If we have a Gaussian kernel, we need to multiply by gamma and exponentia-
			% te.
			K = exp(-model.Parameters(4)*K);
		end

		% Calculate the decision values for the current block. See LIBSVM FAQ for 
		% the detailed formula.
		dec(mask,:) = bsxfun(@minus,K*sv_coef,model.rho.');

		n = n+length(mask);
	end

	% Prepare the votes matrix, which will contain the votes assigned to each 
	% class for each testing vector.
	votes = zeros(size(dec,1),class_ct);

	for r = 1:size(pairs,2)
		% For each pair, calculate the "winners" and add one to their tally.
		n1 = pairs(1,r);
		n2 = pairs(2,r);

		votes(dec(:,r)>=0,n1) = votes(dec(:,r)>=0,n1)+1;
		votes(dec(:,r)<0,n2) = votes(dec(:,r)<0,n2)+1;
	end

	% Assign the class to that with the largest number of votes.
	[temp,labels] = max(votes,[],2);

	% Translate labels to those used in the model.
	labels = model.Label(labels);
end
