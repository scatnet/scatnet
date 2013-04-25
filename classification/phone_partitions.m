function [prt_train,prt_test,prt_dev] = phone_partition(src)
	prt_train = find([src.objects.subset]==0);
	prt_test = find([src.objects.subset]==1);
	prt_dev = find([src.objects.subset]==2);
end
