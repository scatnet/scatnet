% svm_param_search: Parameter search for SVM classifier.
% Usage
%    [err,C,gamma] = svm_param_search(db, train_set, valid_set, options)
% Input
%    db: The database containing the feature vector.
%    train_set: The object indices of the training instances.
%    valid_set: The object indices of the validation instances.
%    options: The training options passed to svm_train.
% Output
%    err: The errors for the parameters (C,gamma).
%    C: The slack factors tested.
%    gamma: The gammas tested (for Gaussian kernel).

function [err,C,gamma] = svm_param_search(db,train_set,valid_set,opt)
	if nargin < 3
		valid_set = [];
	end
	
	if nargin < 4
		opt = struct();
	end
	
	opt = fill_struct(opt,'gamma',1e-4);
	opt = fill_struct(opt,'C',8);
	opt = fill_struct(opt,'cv_folds',5);
	
	if isempty(valid_set)
		obj_class = [db.src.objects(train_set).class];
		
		ratio = (opt.cv_folds-1)/opt.cv_folds;
		
		[cvtrain_set,cvvalid_set] = create_partition(obj_class,ratio,0);
		cvtrain_set = cvtrain_set;
		cvvalid_set = cvvalid_set;
		
		for f = 1:opt.cv_folds
			[err(:,f),C,gamma] = svm_param_search(db, ...
				train_set(cvtrain_set),train_set(cvvalid_set),opt);
			
			[cvtrain_set,cvvalid_set] = ...
				next_fold(cvtrain_set,cvvalid_set,obj_class);
		end
	else
		r = 1;
		[C,gamma] = ndgrid(opt.C,opt.gamma);
		C = C(:);
		gamma = gamma(:);
		for r = 1:numel(C)
			opt1 = opt;
			opt1.C = C(r);
			opt1.gamma = gamma(r);
			
			fprintf('testing C = %f, gamma = %f.\n',opt1.C,opt1.gamma);

			tm0 = tic;
			model = svm_train(db,train_set,opt1);
			labels = svm_test(db,model,valid_set);

			err(r,1) = classif_err(labels,valid_set,db.src);

			fprintf('\terror = %f (%.2f seconds).\n',err(r,1),toc(tm0));
		end
	end
end
