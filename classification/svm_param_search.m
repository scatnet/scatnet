% svm_param_search: Parameter search for SVM classifier.
% Usage
%    [err,C,gamma] = svm_param_search(db, prt_train, prt_dev, options)
% Input
%    db: The database containing the feature vector.
%    prt_train: The object indices of the training instances.
%    prt_dev: The object indices of the validation instances.
%    options: The training options passed to svm_train.
% Output
%    err: The errors for the parameters (C,gamma).
%    C: The slack factors tested.
%    gamma: The gammas tested (for Gaussian kernel).

function [err,C,gamma] = svm_param_search(db,prt_train,prt_dev,opt)
	if nargin < 3
		prt_dev = [];
	end
	
	if nargin < 4
		opt = struct();
	end
	
	opt = fill_struct(opt,'gamma',1e-4);
	opt = fill_struct(opt,'C',8);
	opt = fill_struct(opt,'cv_folds',5);
	
	if isempty(prt_dev)
		obj_class = [db.src.objects(prt_train).class];
		
		ratio = (opt.cv_folds-1)/opt.cv_folds;
		
		[prt_cvtrain,prt_cvdev] = create_partition(obj_class,ratio,0);
		prt_cvtrain = prt_cvtrain;
		prt_cvdev = prt_cvdev;
		
		for f = 1:opt.cv_folds
			[err(:,f),C,gamma] = svm_param_search(db, ...
				prt_train(prt_cvtrain),prt_train(prt_cvdev),opt);
			
			[prt_cvtrain,prt_cvdev] = ...
				next_fold(prt_cvtrain,prt_cvdev,obj_class);
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
			model = svm_train(db,prt_train,opt1);
			labels = svm_test(db,model,prt_dev);

			err(r,1) = classif_err(labels,prt_dev,db.src);

			fprintf('\terror = %f (%.2f seconds).\n',err(r,1),toc(tm0));
		end
	end
end
