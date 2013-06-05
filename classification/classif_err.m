% classif_err: Calculates the classification error.
% Usage
%    err = classif_err(labels, test_set, src)
% Input
%    labels: The predicted labels corresponding to the testing instances.
%    test_set: The object indices of the testing instances.
%    src: The source from which the objects were taken.
% Output
%    err: The classification error.

function err = classif_err(labels,test_set,src)
	truth = [src.objects(test_set).class];

	if isfield(src,'cluster')
		cluster = src.cluster;
	else
		cluster = 1:max(truth);
	end
	
	err = 1-sum(bsxfun(@eq,cluster(labels),cluster(truth)),2)/length(truth);
end
