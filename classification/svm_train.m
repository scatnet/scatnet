% SVM_TRAIN Train an SVM classifier
%
% Usage
%    model = SVM_TRAIN(db, train_set, options)
%
% Input
%    db (struct): The database containing the feature vector.
%    train_set (int): The object indices of the training instances.
%    options (struct): The training options:
%          options.kernel_type (char): The kernel type: 'linear' or 'gaussian'
%             (default 'gaussian').
%          options.C (numeric): The slack factor (default 8).
%          options.gamma (numeric): The gamma of the Gaussian kernel (default 
%             1e-4).
%          options.no_inplace (boolean): Do not use the inplace version of 
%             LIBSVM, even if it available (default false).
%          options.full_test_kernel (boolean): Explicity calculate the test
%             kernel instead of relying on the precalculated kernel. Used if 
%             the kernel is only defined on the training vectors (default 
%             false).
%          options.w (boolean): Add weights to rebalance the training set if 
%             it is imbalanced. The rebalancing is done so that the distribu-
%             tion of the training samples seem to be uniform for all the 
%             classes (default 0).
%
% Output
%    model (struct): The SVM model.
%
% Description
%    The svm_train function provides an interface to the LIBSVM set of
%    SVM training routines. If available, will use the inplace version found
%    in libsvm-compact (see http://www.di.ens.fr/data/software/) to save
%    memory and speed up calculations.
%
% See also
%    SVM_TEST, CLASSIF_ERR, CLASSIF_RECOG

function model = svm_train(db,train_set,opt)
	if nargin < 3
		opt = struct();
	end

	% Set default options.
	opt = fill_struct(opt, 'no_inplace', 0);
	opt = fill_struct(opt, 'full_test_kernel', 0);

	opt = fill_struct(opt, 'kernel_type', 'gaussian');

	opt = fill_struct(opt, 'gamma', 1e-4);
	opt = fill_struct(opt, 'C', 8);
	opt = fill_struct(opt, 'w', 0);
	opt = fill_struct(opt, 'b', 0);

	% Extract feature vector indices of the objects in the training set and their
	% respective classes.
	ind_features = [];
	feature_class = [];
	for k = 1:length(train_set)
		ind = db.indices{train_set(k)};
		ind_features = [ind_features ind];
		feature_class = [feature_class ...
			db.src.objects(train_set(k)).class*ones(1,length(ind))];
	end

	% Is there are pre-calculated kernel of the same type as specified in the op-
	% tions?
	precalc_kernel = isfield(db,'kernel') && ...
		strcmp(opt.kernel_type,db.kernel.kernel_type);

	% Slackness parameter is always specified.
	params = ['-q -c ' num2str(opt.C)];
	if ~precalc_kernel
		% Non-precalculated kernel - specify type to LIBSVM.
		if strcmp(opt.kernel_type,'linear')
			params = [params ' -t 0'];
		elseif strcmp(opt.kernel_type,'gaussian')
			% Gaussian kernel - also give gamma parameter.
			params = [params ' -t 2 -g ' num2str(opt.gamma)];
		else
			error('Unknown kernel type!');
		end
		% Feature matrix for LIBSVM is just the submatrix containing the training
		% feature vectors.
		features = db.features(:,ind_features);
	else
		% Precalculated kernel. If inplace version of LIBSVM is available, we pass
		% it the kernel plus a mask, otherwise we extract the relevant parts of the
		% kernel.

		% If only parts of the training feature vectors are included among the vec-
		% tors in the kernel, use only those.
		[kernel_mask,kernel_ind] = ismember(1:size(db.features,2),db.kernel.kernel_set);
		ind_features = kernel_ind(ind_features(kernel_mask(ind_features)));

		if exist('svmtrain_inplace') && ~opt.no_inplace
			% The inplace version of LIBSVM exists and we can use it.

			% Calculate the classes for the vectors in the kernel. 
			feature_class = zeros(1,size(db.features,2));
			for k = 1:length(db.indices)
				feature_class(db.indices{k}) = db.src.objects(k).class;
			end
			feature_class = feature_class(db.kernel.kernel_set);

			% Send the whole kernel to LIBSVM.
			features = db.kernel.K;

			if strcmp(db.kernel.kernel_type,'linear') && ...
				strcmp(db.kernel.kernel_format,'square')
				% Feature matrix contains kernel values in square form.
				params = [params ' -t 4'];
			elseif strcmp(db.kernel.kernel_type,'linear') && ...
				strcmp(db.kernel.kernel_format,'triangle')
				% Feature matrix contains kernel values in triangular form.
				params = [params ' -t 5'];
			elseif strcmp(db.kernel.kernel_type,'gaussian') && ...
				strcmp(db.kernel.kernel_format,'square')
				% Feature matrix contains \|x_i-x_j\|^2 in square form. To obtain a Gauss-
				% ian kernel, LIBSM thus needs to multiply by -gamma and exponentiate.
				params = [params ' -t 6 -g ' num2str(opt.gamma)];
			elseif strcmp(db.kernel.kernel_type,'gaussian') && ...
				strcmp(db.kernel.kernel_format,'triangle')
				% Same as above, but in triangular form.
				params = [params ' -t 7 -g ' num2str(opt.gamma)];
			else
				error('Unknown kernel type/format!');
			end
		else
			% We don't have the inplace version of LIBSVM. 
			params = [params ' -t 4'];

			if strcmp(db.kernel.kernel_format, 'triangle')
				error(['Triangular kernels not supported for standard ' ...
					' LIBSVM version. Please try libsvm-compact.'])
			end
			
			% Send the part of the kernel containing the training vector columns.
			features = db.kernel.K(:,ind_features);

			if strcmp(db.kernel.kernel_type,'gaussian')
				% Since this version of LIBSVM doesn't support on-the-fly exponentiation,
				% we calculate the correct Gaussian kernel here.
				features(2:end,:) = exp(-opt.gamma*features(2:end,:));
				params = [params ' -g ' num2str(opt.gamma)];
			end
		end
	end

	if opt.w > 0
		% If reweighting to obtain uniform distribution is needed, add the weights.
		db_weights = calc_train_weights(db, train_set, opt);
		params = [params db_weights];
	end

	% Probability outputs?
	params = [params ' -b ' num2str(opt.b)];

	% Are we to calculate complete kernel when testing?
	model.full_test_kernel = opt.full_test_kernel;

	% Which vectors were used to train the SVM?
	model.train_set = train_set;

	% Call the desired LIBSVM routine.
	if ~exist('svmtrain_inplace') || opt.no_inplace
		model.svm = svmtrain(double(feature_class.'), ...
			double(features.'),params);
	else
		% To specify the training vectors, ind_features is passed as a mask.
		model.svm = svmtrain_inplace(feature_class, ...
			single(features),params,ind_features);
	end
end

function db_weights = calc_train_weights(db,train_set,opt)
	% the weight of a particular class is always the inverse of the total
	% number of its training features, even in the cross_validation phase!

	ind_objs={};
	ind_feats={};
	nb_feats=[];

	db_weights=[];

	if opt.w == 1
		factor = 1;
	elseif opt.w == 2
		factor = opt.cv_folds/(opt.cv_folds-1);
	else
		error('opt.w must be equal to 1 or 2!');
	end

	for k = 1:length(db.src.classes)
		ind_objs{k} = find([db.src.objects.class]==k);

		ind_feats{k} = [db.indices{ind_objs{k}}];

		mask2 = ismember(ind_feats{k},[db.indices{train_set}]);
		ind_maxp2 = find(mask2>0);
		ind_feats{k} = ind_feats{k}(ind_maxp2);

		nb_feats(k) = factor*numel(ind_feats{k});

		db_weights = [db_weights ' -w' num2str(k) ' ' num2str(1/nb_feats(k))];
	end
end
