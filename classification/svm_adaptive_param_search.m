function [err,C,gamma] = svm_adaptive_param_search(db,prt_train,prt_dev,opt)
	gamma0 = opt.gamma;
	C0 = opt.C;

	for k = 1:opt.search_depth
		[err{k},C{k},gamma{k}] = svm_param_search(db,prt_train,prt_dev,opt);
	
		[temp,ind] = min(mean(err{k},2));
		
		step = exp(1/2*mean(log(C0(2:end))-log(C0(1:end-1))));
		C0 = [step^(-1) 1 step]*C{k}(ind);
		
		step = exp(1/2*mean(log(gamma0(2:end))-log(gamma0(1:end-1))));
		gamma0 = [step^(-1) 1 step]*gamma{k}(ind);

		opt.C = C0;
		opt.gamma = gamma0;
	end
end
