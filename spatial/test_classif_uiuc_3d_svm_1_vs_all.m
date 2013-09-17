%% load any db
nClass = 25;
nPerClass = 40;
feat = convert_feat_format(db2, nClass, nPerClass);


options.C = 1000;
options.Ntrain = 20;

out = svm_one_vs_all(feat, options);
mean(out.score_avg)
