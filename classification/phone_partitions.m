function [prt_train,prt_test,prt_dev] = phone_partition(src)
	prt_train = find([src.segments.subset]==0);
	prt_test = find([src.segments.subset]==1);
	prt_dev = find([src.segments.subset]==2);
end
