% SVM_PARAM_SEARCH Parameter search for SVM classifier
%
% Usage
%    [err, C, gamma] = SVM_PARAM_SEARCH(db, train_set, valid_set, options)
%
% Input
%    db (struct): The database containing the feature vector.
%    train_set (int): The object indices of the training instances.
%    valid_set (int): The object indices of the validation instances.
%    options (struct): The training options passed to svm_train.
%
% Output
%    err (numeric): The errors for the parameters (C, gamma).
%    C (numeric): The slack factors tested.
%    gamma (numeric): The gammas tested (for Gaussian kernel).
%
% See also
%    SVM_TRAIN, SVM_TEST, SVM_ADAPTIVE_PARAM_SEARCH

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
	opt = fill_struct(opt,'reweight',0);


	if isempty(valid_set)	
		obj_class = [db.src.objects(train_set).class];
		
		ratio = (opt.cv_folds-1)/opt.cv_folds;
		
		[cvtrain_set,cvvalid_set] = create_partition(obj_class,ratio,0);
		cvtrain_set = cvtrain_set;
		cvvalid_set = cvvalid_set;

		% TODO: Check for empty validation set.
		
		% If some reweighting is needed let svm_train know that even in
		% this phase, the weigths should be computed base on the total
		% training_set, set opt.reweight to 2.
		% opt.reweight can take the value of 2 only during cross_validation!
		
		for f = 1:opt.cv_folds
			[err(:,f),C,gamma] = svm_param_search(db, ...
				train_set(cvtrain_set),train_set(cvvalid_set),opt);
			
			[cvtrain_set,cvvalid_set] = ...
				next_fold(obj_class,cvtrain_set,cvvalid_set);
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
			
			if opt.reweight 
				err(r,1) = classif_mean_err_rate(labels,valid_set,db.src);
			else
				err(r,1) = classif_err(labels,valid_set,db.src);
			end
			
			fprintf('\terror = %f (%.2f seconds).\n',err(r,1),toc(tm0));
		end
	end

end
