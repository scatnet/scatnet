src = gtzan_src('~/matlab/y/gtzan');

N = 5*2^17;

filt1_opt.Q = 8;
filt1_opt.J = 80;
filt1_opt.gabor = 1;

filt2_opt.Q = 1;
filt2_opt.J = 13;

filters1 = morlet_filter_bank_1d(N,filt1_opt);
filters2 = morlet_filter_bank_1d(N,filt2_opt);

scatt_fun = @(x)(scatt_1d(x,{@(x)(wavemod_1d(x,filters1)),@(x)(wavemod_1d(x,filters2)),@(x)(wavemod_1d(x,filters2))}));
scatt_fun = @(x)(format_scatt(log_scatt(renorm_scatt(scatt_fun(x))),'table'));

db = prepare_database(src,{scatt_fun},struct('feature_sampling',8));

[train_set,test_set] = create_partition(src);

optt.kernel_type = 'gaussian';
optt.C = 2^4;
optt.gamma = 2^(-12);

addpath('~/matlab/libsvm-3.1/matlab');

model = svm_train(db,train_set,optt);
labels = svm_test(db,model,test_set);

err = classif_err(labels,test_set,src);

