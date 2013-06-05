% svm_train: Train an SVM classifier.
% Usage
%    model = svm_train(db, train_set, options)
% Input
%    db: The database containing the feature vector.
%    train_set: The object indices of the training instances.
%    options: The training options. options.kernel_type specifies the kernel
%       type ('linear' or 'gaussian'), options.C specified the slack factor,
%       and options.gamma specifies the gamma constant for the Gaussian kernel
%       case.
% Output
%    model: The SVM model.

function model = svm_train(db,train_set,opt)
	if nargin < 3
		opt = struct();
	end
	
	%if ~exist('svmtrain_inplace')
	%	error('you should make sure svmtrain_inplace is available...');
	%end

	opt = fill_struct(opt,'no_inplace',0);
	opt = fill_struct(opt,'full_test_kernel',0);

	opt = fill_struct(opt,'kernel_type','gaussian');
	
	opt = fill_struct(opt,'gamma',1e-4);
	opt = fill_struct(opt,'C',8);
	
	ind_features = [];
	feature_class = [];
	for k = 1:length(train_set)
		ind = db.indices{train_set(k)};
		ind_features = [ind_features ind];
		feature_class = [feature_class ...
			db.src.objects(train_set(k)).class*ones(1,length(ind))];
	end

	
	precalc_kernel = isfield(db,'kernel') && ...
		strcmp(opt.kernel_type,db.kernel.kernel_type);
	
	params = ['-q -c ' num2str(opt.C)];
	if ~precalc_kernel
		if strcmp(opt.kernel_type,'linear')
			params = [params ' -t 0'];
		elseif strcmp(opt.kernel_type,'gaussian')
			params = [params ' -t 2 -g ' num2str(opt.gamma)];
		else
			error('Unknown kernel type!');
		end
		features = db.features(:,ind_features);
	else
		[kernel_mask,kernel_ind] = ismember(1:size(db.features,2),db.kernel.kernel_set);

		ind_features = kernel_ind(ind_features(kernel_mask(ind_features)));

		if exist('svmtrain_inplace') && ~opt.no_inplace
			feature_class = zeros(1,size(db.features,2));
			for k = 1:length(db.indices)
				feature_class(db.indices{k}) = db.src.objects(k).class;
			end
			feature_class = feature_class(db.kernel.kernel_set);
			features = db.kernel.K;

			if strcmp(db.kernel.kernel_type,'linear') && ...
				strcmp(db.kernel.kernel_format,'square')
				params = [params ' -t 4'];
			elseif strcmp(db.kernel.kernel_type,'linear') && ...
				strcmp(db.kernel.kernel_format,'triangle')
				params = [params ' -t 5'];
			elseif strcmp(db.kernel.kernel_type,'gaussian') && ...
				strcmp(db.kernel.kernel_format,'square')
				params = [params ' -t 6 -g ' num2str(opt.gamma)];
			elseif strcmp(db.kernel.kernel_type,'gaussian') && ...
				strcmp(db.kernel.kernel_format,'triangle')
				params = [params ' -t 7 -g ' num2str(opt.gamma)];
			else
				error('Unknown kernel type/format!');
			end
		else
			params = [params ' -t 4'];
			
			features = db.kernel.K(:,ind_features);
			
			if strcmp(db.kernel.kernel_type,'gaussian')
				features(2:end,:) = exp(-opt.gamma*features(2:end,:));
				params = [params ' -g ' num2str(opt.gamma)];
			end
		end
	end

	model.full_test_kernel = opt.full_test_kernel;

	model.train_set = train_set;
	
	if ~exist('svmtrain_inplace') || opt.no_inplace
		model.svm = svmtrain(feature_class.', ...
			double(features.'),params);
	else
		model.svm = svmtrain_inplace(feature_class, ...
			single(features),params,ind_features);
	end
end
