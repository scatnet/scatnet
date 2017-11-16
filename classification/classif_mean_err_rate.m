% CLASSIF_MEAN_ERR_RATE
%
% Usage
%    [mean_err_rate, err_rates] = ...
%       classif_mean_err_rate(labels, test_set, truth);
%
% Input
%    labels (int): The labels attributed to the testing instances.
%    test_set (int): The object indices of the testing instances.
%    truth (int): The actual labels of the testing instances.
%
% Output
%    mean_err_rate (numeric): The mean error rate.
%    err_rates (numeric): Array containing the individual error rates of each
%       class.
%
% Description
%    This function computes the mean of the error rates of all the classes
%    which are present in the dataset. We have
%
%       mean_err_rate = 1 - mean_recog_rate
%
%    where mean_recog_rate is the mean of all the recognition rates of all the 
%    classes which are present in the dataset and is a widely used measure of
%    the performance of the classifier when the data set is highly unbalanced.
%
% See also
%    SVM_TEST, CLASSIF_ERR, CLASSIF_RECOG

function [mean_err_rate, err_rates] = classif_mean_err_rate(labels, ...
	test_set, truth)

	[recog_mean, recog_rates] = classif_recog(labels, test_set, truth);

	mean_err_rate = 1 - recog_mean;
	err_rates = 1 - recog_rates;
end
