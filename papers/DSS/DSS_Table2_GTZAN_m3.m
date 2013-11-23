% Script to reproduce the experiments leading to the results provided in the
% Table 2 of the paper "Deep Scattering Spectrum" by J. Andén and S. Mallat.

% M=3 scattering

run_name = 'DSS_Table2_GTZAN_m3';

N=5*2^17;

src=gtzan_src('/path/to/gtzan');

fparam.filter_type = {'gabor_1d','morlet_1d','morlet_1d'};
fparam.Q = [8 2 1];
fparam.J = T_to_J(8192,fparam);

options.M = 3;

Wop = wavelet_factory_1d(N, fparam, options);

feature_fun = {@(x)(format_scat(log_scat(renorm_scat(scat(x,Wop)))))};

db = prepare_database(src,feature_fun);
db.features = single(db.features);
db = svm_calc_kernel(db,'gaussian','square',1:2:size(db.features,2));

rs = RandStream.create('mt19937ar','Seed',floor(pi*1e9));
RandStream.setGlobalStream(rs);
[train_set{1}, test_set{1}] = create_partition([src.objects.class], 0.8);
for k = 2:10
	[train_set{k}, test_set{k}] = ...
		next_fold([src.objects.class], train_set{k-1}, test_set{k-1});
end

optt.kernel_type = 'gaussian';
optt.C = 2.^[0:4:8];
optt.gamma = 2.^[-16:4:-8];
optt.search_depth = 3;
optt.full_test_kernel = 0;

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
	labels(:,k) = svm_test(db,model,test_set{k});
	err(k) = classif_err(labels(:,k),test_set{k},db.src);

	fprintf('dev err = %f, test err = %f\n',dev_err(k),err(k));

	save([run_name '.mat'],'labels','dev_err','err','C','gamma');
end
