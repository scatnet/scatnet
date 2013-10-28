function [mean_err_rate, err_rates] = classif_mean_err_rate(labels,test_set,truth)

% Usage
%    [mean_err_rate,err_rates] =  classif_mean_err(labels,test_set,truth)
%
% Input
%    labels (int): The labels attributed to the testing instances.
%    test_set (int): The object indices of the testing instances.
%    truth: the actual labels of the testing instances
%
% Output
%    mean_err_rate (real): The mean error rate
%    recog_rate(real): array containing the individual error rates of
% each class.
%
% Description
%    This function computes the mean of the error rates of all the classes
% which are present in the dataset. We have mean_err_rate = 1 - mean_recog_rate
% where mean_recog_rate is the mean of all the recognition rate of all the 
% classes which are present in the dataset and 
% is a widely used measure of the performance of the classifier when the
% data set is highly unbalanced.
%
% See also
%    SVM_TEST, CLASSIF_ERR, CLASSIF_RECOG
  
if  isstruct(truth)
    src = truth;
    truth = [src.objects.class];
end

% Normally, the test_set contains samples of all classes
recog_rates = zeros(1,max(truth));
gdTruth = truth(:,test_set);


parfor k = 1:max(truth)
    
    mask = k == gdTruth;
    good_elts = find(labels==k & mask);
    
    mask1 = numel(find(mask==1));
    recog_rates(k)=numel(good_elts)/mask1;
    
end

err_rates = 1 - recog_rates;
mean_err_rate = 1 - mean(recog_rates);
     
end