src = gtzan_src('/path/to/gtzan/dataset');

N = 5*2^17;
M = 2;
T = 8192;

filt_opt.Q = [8 1];
filt_opt.J = T_to_J(T, filt_opt);

scat_opt.M = 2;

Wop = wavelet_factory_1d(N, filt_opt, scat_opt);

feature_fun = @(x)(format_scat(log_scat(renorm_scat(scat(x, Wop)))));

database_options.feature_sampling = 8;

database = prepare_database(src, feature_fun, database_options);

rs = RandStream.getDefaultStream();
rs.reset();
[train_set, test_set] = create_partition(src, 0.8);

database = svm_calc_kernel(database, 'gaussian');

svm_options.kernel_type = 'gaussian';
svm_options.C = 2.^[0:4:8];
svm_options.gamma = 2.^[-16:4:-8];

[err,C,gamma] = svm_param_search(database, train_set, [], svm_options);

[temp,ind] = min(mean(err,2));
C_best = C(ind);
gamma_best = gamma(ind);

svm_options.C = C_best;
svm_options.gamma = gamma_best;

model = svm_train(database, train_set, svm_options);
labels = svm_test(database, model, test_set);

test_err = classif_err(labels, test_set, src);