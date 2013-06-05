function [err,C,gamma] = svm_adaptive_param_search(db,train_set,valid_set,opt)
	opt = fill_struct(opt,'gamma',1e-4);
	opt = fill_struct(opt,'C',8);

	opt = fill_struct(opt,'search_depth',2);

	gamma0 = opt.gamma;
	C0 = opt.C;

	for k = 1:opt.search_depth
		[err{k},C{k},gamma{k}] = svm_param_search(db,train_set,valid_set,opt);
	
		[temp,ind] = min(mean(err{k},2));
		
		if length(C0) > 1
			step = exp(1/2*mean(log(C0(2:end))-log(C0(1:end-1))));
			C0 = [step^(-1) 1 step]*C{k}(ind);
		end
		
		if length(gamma0) > 1
			step = exp(1/2*mean(log(gamma0(2:end))-log(gamma0(1:end-1))));
			gamma0 = [step^(-1) 1 step]*gamma{k}(ind);
		end

		opt.C = C0;
		opt.gamma = gamma0;
	end
end
