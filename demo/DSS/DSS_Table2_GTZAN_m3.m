% M=3 scattering, cv parameters

run_name = 'DSS_Table2_GTZAN_m3_Q2';

tic

N=5*2^17;
src=gtzan_src('/home/anden/GTZAN/gtzan');

[prt_train,prt_test] = create_partition(src);

fparam.filter_type = {'gabor_1d','morlet_1d','morlet_1d'};
fparam.Q = [8 2 1];
fparam.J = T_to_J(8192,fparam.Q);% length of a music of 30s  = 22*30000
options = struct();
Wavelet = wavelet_factory_1d(N, fparam,options, 3);
feature_fun = {@(x)((squeeze(format_scat(log_scat(renorm_scat(scat(x,Wavelet)))))))};


%matlabpool 8

db = prepare_database(src,feature_fun);
db.features = single(db.features)
db = svm_calc_kernel(db,'gaussian','square',1:2:size(db.features,2));
load('~/matlab/scattlab1d/prts-gtzan.mat');



optt.kernel_type = 'gaussian';
optt.C = 2.^[0:4:8];
optt.gamma = 2.^[-16:4:-8];
optt.search_depth = 3;
optt.full_test_kernel = 0;

addpath('~/cpp/libsvm-dense-compact-3.12/matlab');

for k = 1:10
	[dev_err_grid,C_grid,gamma_grid] = svm_adaptive_param_search(db,prt_train{k},[],optt);

	[dev_err(k),ind] = min(mean(dev_err_grid{end},2));
	C(k) = C_grid{end}(ind);
	gamma(k) = gamma_grid{end}(ind);

	optt1 = optt;
	optt1.C = C(k);
	optt1.gamma = gamma(k);

	model = svm_train(db,prt_train{k},optt1);
	labels = svm_test(db,model,prt_test{k});
	err(k) = classif_err(labels,prt_test{k},db.src);

	fprintf('dev err = %f, test err = %f\n',dev_err(k),err(k));

	save([run_name '.mat'],'dev_err','err','C','gamma');
end


toc
