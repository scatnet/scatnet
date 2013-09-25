function out = svm_one_vs_all(feat,options)
% 22 nov 2012 - laurent sifre
options.null = 1;
C = getoptions(options,'C',0.0003);
Niter = getoptions(options,'Niter',5);
Ntrain = getoptions(options,'Ntrain',10);
Ntestmax = getoptions(options,'Ntestmax',100000000);

for iter = 1:Niter
    % split db between training and testing with pseudorandom split
    [feat_train,feat_test,train_id,test_id] = classif_split(feat,Ntrain,iter,Ntestmax);
    
    % stack
    [training_instance_matrix,infos_train] = classif_stack_all(feat_train);
    training_label_vector = (infos_train(:,1));
    [testing_instance_matrix,infos_test] = classif_stack_all(feat_test);
    testing_label_vector = (infos_test(:,1));
    
    % compute kernels
    Ktraintrain  = training_instance_matrix * training_instance_matrix';
    Ktesttrain = testing_instance_matrix * training_instance_matrix';
    
    % for each class predict one vs all
    for c  = 1:numel(feat)
        
        train_lab_one_vs_all = double(training_label_vector == c);
        test_lab_one_vs_all = double(testing_label_vector == c);
        % how to feed libsvm with precomputed kernel  :
        % http://sun360.csail.mit.edu/code/cvpr2012pano_codeRelease/code/libsvm-mat-2.89-3/README
        svmop = sprintf('-t 4 -c %s -q', num2str(C));
        model = svmtrain(train_lab_one_vs_all,[(1:numel(train_lab_one_vs_all))' Ktraintrain],svmop);
        [~,~,score]=svmpredict(test_lab_one_vs_all,[(1:numel(test_lab_one_vs_all))',Ktesttrain],model);
        if c==1 
            score = -score; % due to a strange behaviour of libsvm
        end
        score_one_vs_all(:,c) = score;
    end
    
    [~,predicted_label] = min(score_one_vs_all,[],2);
    
    % reformat label
    k = 1;
    for c = 1:numel(feat_test)
        reformated_label{c} = predicted_label(k + (0:numel(feat_test{c})-1));
        k = k + numel(feat_test{c});
    end
    classif = classif_stat_score(reformated_label);
    out.all{iter} = classif;
    out.score_avg(iter) = classif.score_avg;
    out.score_per_class_avg(iter) = classif.score_per_class_avg;
end
