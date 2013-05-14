% next_fold: Calculates the next fold in an N-fold cross validation.
% Usage
%    [train_set, test_set] = next_fold(train_set, test_set, obj_class)
% Input
%    train_set: The training set of the current fold.
%    test_set: The testing set of the current fold.
%    obj_class: The classes of the objects in the database. The sets train_set
%       and test_set contain indexes of obj_class.
% Output
%    train_set: The training set of the next fold.
%    test_set: The testing set of the next fold.
% Description
%    For each class, next_fold extracts its training and testing sets. These 
%    are then permuted so that the old testing set is at the beginning of the
%    new training set and that theend of the old training set becomes the new
%    testing set. For example, if the training and testing sets were divided
%    into blocks of the same size, we have the old sets
%        TRAIN: 1 2 3 4, TEST: 5,
%    the new sets will be
%        TRAIN: 5 1 2 3, TEST: 4.
%    In this way, five-fold cross-validation is obtained by calling next_fold
%    four times to cycle through the different folds.

function [train_set, test_set] = next_fold(train_set, test_set, obj_class)
	cv_folds = (length(train_set)+length(test_set))/length(test_set);
	
	for k = 1:max(obj_class)
		ind_class = find(obj_class==k);
		
		ind_train = find(ismember(train_set,ind_class));
		ind_test = find(ismember(test_set,ind_class));
		
		prt_class = [test_set(ind_test) train_set(ind_train)];
		
		train_set(ind_train) = prt_class(1:length(ind_train));
		test_set(ind_test) = prt_class(length(ind_train)+1:end);
	end
end