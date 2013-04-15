function err = classif_err(labels,prt_test,src)
	truth = [src.objects(prt_test).class];

	if isfield(src,'cluster')
		cluster = src.cluster;
	else
		cluster = 1:max(truth);
	end
	
	err = 1-sum(bsxfun(@eq,cluster(labels),cluster(truth)),2)/length(truth);
end
