function [rg_mean,recog_rate] = classif_recog(labels,test_set,truth)

    if isstruct(truth)
        src = truth;
        truth = [src.objects.class];
    end

    % Normally, the test_set contains samples of all classes
    recog_rate = zeros(1,max(truth));
    gdTruth = truth(:,test_set);


    for k=1:max(truth)

        mask=k == gdTruth;
        good_elts = find(labels==k & mask);

        mask1 = numel(find(mask==1));
        recog_rate(k) = numel(good_elts)/mask1;

    end

    rg_mean=mean(recog_rate);
end


