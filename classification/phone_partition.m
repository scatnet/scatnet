% phone_partition: Specifies training, testing and development sets for TIMIT
% Usage
%    [train_set, test_set, dev_set] = phone_partition(src)
% Input
%    src: The TIMIT phone source, obtained from phone_src.
% Output
%    train_set: The standard training set (TRAIN).
%    test_set: The core testing set (TEST, 24 speakers).
%    dev_set: The standard development set (TEST, 50 speakers).
% Description:
%    Extracts the indices of the phones in src in the standard TRAIN set, the
%    core TEST set of 24 speakers, and the standard development set in TEST
%    consisting of 50 speakers [1]. For a listing of the latter, see Halberstadt.
%    Note that if src does not contain all the phrases in the relevant sets,
%    phone_partition only extracts those phones that are present.
% References
%    [1] A. K. Halberstadt, “Heterogeneous acoustic measurements and multiple 
%       classiﬁers for speech recognition,” Ph.D. dissertation, Massachusetts
%       Institute of Technology, 1998. 


function [train_set, test_set, dev_set] = phone_partition(src)
	train_set = find([src.objects.subset]==0);
	test_set = find([src.objects.subset]==1);
	dev_set = find([src.objects.subset]==2);
end
