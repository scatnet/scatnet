% classif_err: Calculates the classification error.
% Usage
%    err = classif_err(labels, prt_test, src)
% Input
%    labels: The predicted labels corresponding to the testing instances.
%    prt_test: The object indices of the testing instances.
%    src: The source from which the objects were taken.
% Output
%    err: The classification error.

function err = classif_err(labels,prt_test,src)
	truth = [src.objects(prt_test).class];

	if isfield(src,'cluster')
		cluster = src.cluster;
	else
		cluster = 1:max(truth);
	end
	
	err = 1-sum(bsxfun(@eq,cluster(labels),cluster(truth)),2)/length(truth);
end
