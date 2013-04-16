% create_partition: Creates a train/test partition.
% Usage
%    [prt_train, prt_test] = create_partition(src, ratio)
% Input
%    src: The source structure describing the objects.
%    ratio: The proportion of all instances selected for training.
% Output
%    prt_train: The indices of objects in src.objects corresponding to 
%       training instances.
%    prt_test: The indices of objects in src.objects corresponding to 
%       testing instances.

function [prt_train,prt_test,prt_dev] = create_partition(obj_class,ratio,shuffle)
	if nargin < 1
		error('Must specify a source or a list of object classes!');
	end
	
	if nargin < 2
		ratio = 0.8;
	end

	if nargin < 3
		shuffle = 1;
	end

	if isstruct(obj_class)
		src = obj_class;
		obj_class = [src.objects.class];
	end
	
	if length(ratio) == 1
		ratio = [ratio 1-ratio];
	end
	
	if length(ratio) == 2
		ratio = [ratio 0];
	end
	
	if abs(sum(ratio)-1) > eps
		error('Ratios must add up to 1!');
	end
	
	prt_train = [];
	prt_test = [];
	prt_dev = [];
	
	for k = 1:max(obj_class)
		ind = find(obj_class==k);
		
		if shuffle
			ind = ind(randperm(length(ind)));
		end

		n_train = round(ratio(1)*length(ind));
		if ratio(3) == 0
			n_test = length(ind)-n_train;
			n_dev = 0;
		else
			n_test = round(ratio(2)*length(ind));
			n_dev = length(ind)-n_train-n_test;
		end
		
		prt_train = [prt_train ind(1:n_train)];
		prt_test = [prt_test ind(n_train+1:n_train+n_test)];
		prt_dev = [prt_dev ind(n_train+n_test+1:n_train+n_test+n_dev)];
	end
end
