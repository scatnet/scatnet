function [prt_train,prt_test] = next_fold(prt_train,prt_test,obj_class)
	cv_folds = (length(prt_train)+length(prt_test))/length(prt_test);
	
	for k = 1:max(obj_class)
		ind_class = find(obj_class==k);
		
		ind_train = find(ismember(prt_train,ind_class));
		ind_test = find(ismember(prt_test,ind_class));
		
		prt_class = [prt_test(ind_test) prt_train(ind_train)];
		
		prt_train(ind_train) = prt_class(1:length(ind_train));
		prt_test(ind_test) = prt_class(length(ind_train)+1:end);
	end
end