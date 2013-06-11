% Script to reproduce the experiments leading to the results provided in the
% Table 2 of the paper "Deep Scattering Spectrum" by J. Andén and S. Mallat.

% M=1 scattering

run_name = 'DSS_Table2_GTZAN_m1';

N=5*2^17;

src=gtzan_src('/path/to/gtzan');

fparam.filter_type = {'gabor_1d','morlet_1d'};
fparam.Q = [8 2];
fparam.J = T_to_J(8192,fparam.Q);

options.M = 1;

Wop = wavelet_factory_1d(N, fparam, options);

feature_fun = {@(x)(format_scat(log_scat(renorm_scat(scat(x,Wop)))))};

db = prepare_database(src,feature_fun);
db.features = single(db.features)
db = svm_calc_kernel(db,'gaussian','square',1:2:size(db.features,2));

partitions = load('prts-gtzan.mat');
train_set = partitions.prt_train;
test_set = partitions.prt_test;

optt.kernel_type = 'gaussian';
optt.C = 2.^[0:4:8];
optt.gamma = 2.^[-16:4:-8];
optt.search_depth = 3;
optt.full_test_kernel = 1;

for k = 1:10
	[dev_err_grid,C_grid,gamma_grid] = ...
		svm_adaptive_param_search(db,train_set{k},[],optt);

	[dev_err(k),ind] = min(mean(dev_err_grid{end},2));
	C(k) = C_grid{end}(ind);
	gamma(k) = gamma_grid{end}(ind);

	optt1 = optt;
	optt1.C = C(k);
	optt1.gamma = gamma(k);

	model = svm_train(db,train_set{k},optt1);
	labels = svm_test(db,model,test_set{k});
	err(k) = classif_err(labels,test_set{k},db.src);

	fprintf('dev err = %f, test err = %f\n',dev_err(k),err(k));

	save([run_name '.mat'],'dev_err','err','C','gamma');
end














