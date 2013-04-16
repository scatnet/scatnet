% affine_param_search: Parameter search for affine classifier.
% Usage
%    [err,dim] = affine_param_search(db, prt_train, prt_dev, options)
% Input
%    db: The database containing the feature vector.
%    prt_train: The object indices of the training instances.
%    prt_dev: The object indices of the validation instances.
%    options: The training options passed to affine_train.
% Output
%    err: The errors for the dimensions in dim.
%    dim: The dimensions tested.

function [err,dim] = affine_param_search(db,prt_train,prt_dev,opt)
	if nargin < 3
		prt_dev = [];
	end
	
	if nargin < 4
		opt = struct();
	end
	
	opt = fill_struct(opt,'dim',0:160);
	opt = fill_struct(opt,'cv_folds',5);
	
	if isempty(prt_dev)
		obj_class = [db.src.objects(prt_train).class];
		
		ratio = (opt.cv_folds-1)/opt.cv_folds;
		
		[prt_cvtrain,prt_cvdev] = create_partition(obj_class,ratio,0);
		prt_cvtrain = prt_cvtrain;
		prt_cvdev = prt_cvdev;
		
		for f = 1:opt.cv_folds
			err(:,f) = affine_param_search(db, ...
				prt_train(prt_cvtrain),prt_train(prt_cvdev),opt);
			
			[prt_cvtrain,prt_cvdev] = ...
				next_fold(prt_cvtrain,prt_cvdev,obj_class);
		end
	else
		model = affine_train(db,prt_train,opt);
		labels = affine_test(db,model,prt_dev);
		
		err = classif_err(labels,prt_dev,db.src);
	end	
		
	dim = opt.dim;
end
