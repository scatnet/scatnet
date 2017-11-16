% CLASSIF_RECOG Calculates the average recognition rate
%
% Usage
%    [recog_mean, recog_rates] = CLASSIF_RECOG(labels, test_set, truth);
%
% Input
%    labels (int): The labels attributed to the testing instances.
%    test_set (int): The object indices of the testing instances.
%    truth (int): the actual labels of the testing instances.
%          
% Output
%    recog_mean (numeric): The mean recognition rate
%    recog_rates (numeric): array containing the individual recognition rates of
%       each class.
%
% Description
%    This function computes the average recognition rate of each class.
%    It is a widely used measure of the performance of the classifier when the
%    data set is highly unbalanced.
%
% See also
%    SVM_TEST, CLASSIF_ERR

function [recog_mean, recog_rates]=classif_recog(labels, test_set, truth)
    if isstruct(truth)
        src = truth;
        truth = [src.objects.class];
    end

    % Normally, the test_set contains samples of all classes
    recog_rates = zeros(1, max(truth));
    gdTruth = truth(:,test_set);

    for k=1:max(truth)
        mask = k==gdTruth;
        good_elts = find(labels==k & mask);

        recog_rates(k) = numel(good_elts)/sum(mask);
    end

    recog_mean = mean(recog_rates(isfinite(recog_rates)));
end
