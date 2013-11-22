% AFFINE_PARAM_SEARCH Parameter search for affine classifier
%
% Usage
%    [err, dim] = AFFINE_PARAM_SEARCH(db, train_set, valid_set, options)
%
% Input
%    db (struct): The database containing the feature vector.
%    train_set (int): The object indices of the training instances.
%    valid_set (int): The object indices of the validation instances.
%    options (struct): The training options passed to affine_train.
%
% Output
%    err: The errors for the dimensions in dim.
%    dim: The dimensions tested.
%
% See also
%    AFFINE_TRAIN, AFFINE_TEST

function [err,dim] = affine_param_search(db,train_set,valid_set,opt)
	if nargin < 3
		valid_set = [];
	end
	
	if nargin < 4
		opt = struct();
	end
	
	opt = fill_struct(opt,'dim',0:160);
	opt = fill_struct(opt,'cv_folds',5);
	
	if isempty(valid_set)
		obj_class = [db.src.objects(train_set).class];
		
		ratio = (opt.cv_folds-1)/opt.cv_folds;
		
		[cvtrain_set,cvvalid_set] = create_partition(obj_class,ratio,0);
		cvtrain_set = cvtrain_set;
		cvvalid_set = cvvalid_set;
		
		for f = 1:opt.cv_folds
			err(:,f) = affine_param_search(db, ...
				train_set(cvtrain_set),train_set(cvvalid_set),opt);
			
			[cvtrain_set,cvvalid_set] = ...
				next_fold(obj_class,cvtrain_set,cvvalid_set);
		end
	else
		model = affine_train(db,train_set,opt);
		labels = affine_test(db,model,valid_set);
		
		err = classif_err(labels,valid_set,db.src);
	end	
		
	dim = opt.dim;
end
