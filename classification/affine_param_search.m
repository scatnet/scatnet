function [best_err,best_dim,err] = affine_param_search(db,prt_train,prt_dev,opt)
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
			[temp1,temp2,err(:,f)] = affine_param_search(db, ...
				prt_train(prt_cvtrain),prt_train(prt_cvdev),opt);
			
			[prt_cvtrain,prt_cvdev] = ...
				next_fold(prt_cvtrain,prt_cvdev,obj_class);
		end
	else
		model = affine_train(db,prt_train,opt);
		labels = affine_test(db,model,prt_dev);
		
		err = classif_err(labels,prt_dev,db.src);
	end	
		
	[best_err,dim_ind] = min(mean(err,2),[],1);
	
	best_dim = opt.dim(dim_ind);
end
