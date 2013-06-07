run_name = 'test_gtzan_svm';

src = gtzan_src('~/matlab/y/gtzan');

N = 5*2^17;

filt_opt.filter_type = {'gabor_1d','morlet_1d'};
filt_opt.Q = [8 1];
filt_opt.J = T_to_J(8192,filt_opt.Q);

cascade = cascade_factory_1d(N, filt_opt, struct(), 2);

scatt_fun = @(x)(scatt(x,cascade));
scatt_fun = @(x)(squeeze(format_scatt(log_scatt(renorm_scatt(scatt_fun(x)))))');

db = prepare_database(src,{scatt_fun},struct('feature_sampling',1));

db.features = single(db.features);

db = svm_calc_kernel(db,'gaussian','square',1:2:size(db.features,2));

[train_set,test_set] = create_partition(src);

model = svm_train(db,train_set,optt);
labels = svm_test(db,model,test_set);

err = classif_err(labels,test_set,src);

