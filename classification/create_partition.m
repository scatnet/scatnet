% CREATE_PARTITION Creates a train/test partition
%
% Usage
%    [train_set, test_set] = CREATE_PARTITION(src, ratio, shuffle)
%
%    [train_set, test_set] = CREATE_PARTITION(obj_class, ratio, shuffle)
%
% Input
%    src (struct): The source structure describing the objects.
%    ratio (numeric, optional): The proportion of all instances selected for 
%       training (default 0.8).
%    shuffle (boolean, optional): If true, objects are shuffled before assign-
%       ing partitions (default 1).
%    obj_class (integer): The indices of the classes each object belongs to.
%       Can be obtained from src through [src.objects.class].
%
% Output
%    train_set (int): The indices of objects in src.objects corresponding to 
%       training instances.
%    test_set (int): The indices of objects in src.objects corresponding to 
%       testing instances.
%
% See also
%    CREATE_SRC, NEXT_FOLD

function [train_set,test_set,valid_set] = create_partition(obj_class, ...
	ratio,shuffle)
	
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
	
	train_set = [];
	test_set = [];
	valid_set = [];
	
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
		
		train_set = [train_set ind(1:n_train)];
		test_set = [test_set ind(n_train+1:n_train+n_test)];
		valid_set = [valid_set ind(n_train+n_test+1:n_train+n_test+n_dev)];
	end
end
