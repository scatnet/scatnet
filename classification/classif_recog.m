% CLASSIF_RECOG Calculates the average recognition rate
%
% Usage
%    [rr_mean,recog_rate] =  CLASSIF_RECOG(labels,test_set,truth)
%
% Input
%    labels (int): The labels attributed to the testing instances.
%    test_set (int): The object indices of the testing instances.
%    truth: the actual labels of the testing instances
%          
% Output
%    rr_mean (real): The mean recognition rate
%    recog_rate(real): array containing the individual recognition rates of
%       each class.
%
% Description
%    This function computes the average recognition rate of each class.
%    It is a widely used measure of the performance of the classifier when the
%    data set is highly unbalanced.
%
% See also
%    SVM_TEST, CLASSIF_ERR, CLASSIF_RECOG

function [rg_mean,recog_rate]=classif_recog(labels,test_set,truth)
    if isstruct(truth)
        src=truth;
        truth = [src.objects.class];
    end

    % Normally, the test_set contains samples of all classes
    recog_rate=zeros(1,max(truth));
    gdTruth=truth(:,test_set);

    for k=1:max(truth)
        mask=k==gdTruth;
        good_elts=find(labels==k & mask);

        mask1=numel(find(mask==1));
        recog_rate(k)=numel(good_elts)/mask1;
    end

    rg_mean=mean(recog_rate);
end

