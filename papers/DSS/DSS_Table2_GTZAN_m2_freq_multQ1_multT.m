% Script to reproduce the experiments leading to the results provided in the
% Table 2 of the paper "Deep Scattering Spectrum" by J. Andén and S. Mallat.

% M=2 scattering, frequency scattering, multiple Q1, multiple T

run_name = 'DSS_Table2_GTZAN_m2_freq_multQ1_multT';

src = gtzan_src('/path/to/gtzan');

N = 5*2^17;

filt1_opt.filter_type = {'gabor_1d','morlet_1d'};
filt1_opt.Q = [8 1];
filt1_opt.J = T_to_J(8192,filt1_opt);

sc1_opt.M = 2;

ffilt1_opt.filter_type = 'morlet_1d';
ffilt1_opt.J = 7;

fsc1_opt.M = 1;

Wop1 = wavelet_factory_1d(N, filt1_opt, sc1_opt);
fWop1 = wavelet_factory_1d(128, ffilt1_opt, fsc1_opt);

scatt_fun1 = @(x)(log_scat(renorm_scat(scat(x,Wop1))));
fscatt_fun1 = @(x)(func_output(@scat_freq,2,scatt_fun1(x),fWop1));
feature_fun1 = @(x)(format_scat(fscatt_fun1(x)));

filt2_opt = filt1_opt;
filt2_opt.Q = [1 1];
filt2_opt.J = T_to_J(8192,filt2_opt);

sc2_opt = sc1_opt;

ffilt2_opt = ffilt1_opt;
ffilt2_opt.J = 5;

fsc2_opt = fsc1_opt;

Wop2 = wavelet_factory_1d(N, filt2_opt, sc2_opt);
fWop2 = wavelet_factory_1d(32, ffilt2_opt, fsc2_opt);

scatt_fun2 = @(x)(log_scat(renorm_scat(scat(x,Wop2))));
fscatt_fun2 = @(x)(func_output(@scat_freq,2,scatt_fun2(x),fWop2));
feature_fun2 = @(x)(format_scat(fscatt_fun2(x)));

filt3_opt = filt1_opt;
filt3_opt.J = T_to_J(2*8192,filt3_opt);

sc3_opt = sc1_opt;

Wop3 = wavelet_factory_1d(N, filt3_opt, sc3_opt);

scatt_fun3 = @(x)(log_scat(renorm_scat(scat(x,Wop3))));
fscatt_fun3 = @(x)(func_output(@scat_freq,2,scatt_fun3(x),fWop1));
feature_fun3 = @(x)(format_scat(fscatt_fun3(x)));

filt4_opt = filt2_opt;
filt4_opt.J = T_to_J(2*8192,filt4_opt);

sc4_opt = sc2_opt;

Wop4 = wavelet_factory_1d(N, filt4_opt, sc4_opt);

scatt_fun4 = @(x)(log_scat(renorm_scat(scat(x,Wop4))));
fscatt_fun4 = @(x)(func_output(@scat_freq,2,scatt_fun4(x),fWop2));
feature_fun4 = @(x)(format_scat(fscatt_fun4(x)));

filt5_opt = filt1_opt;
filt5_opt.J = T_to_J(4*8192,filt5_opt);

sc5_opt = sc1_opt;

Wop5 = wavelet_factory_1d(N, filt5_opt, sc5_opt);

scatt_fun5 = @(x)(log_scat(renorm_scat(scat(x,Wop5))));
fscatt_fun5 = @(x)(func_output(@scat_freq,2,scatt_fun5(x),fWop1));
feature_fun5 = @(x)(format_scat(fscatt_fun5(x)));

filt6_opt = filt2_opt;
filt6_opt.J = T_to_J(4*8192,filt6_opt);

sc6_opt = sc2_opt;

Wop6 = wavelet_factory_1d(N, filt6_opt, sc6_opt);

scatt_fun6 = @(x)(log_scat(renorm_scat(scat(x,Wop6))));
fscatt_fun6 = @(x)(func_output(@scat_freq,2,scatt_fun6(x),fWop2));
feature_fun6 = @(x)(format_scat(fscatt_fun6(x)));

features = {feature_fun1, feature_fun2, feature_fun3, ...
	feature_fun4, feature_fun5, feature_fun6};

for k = 1:length(features)
    fprintf('testing feature #%d...',k);
    tic;
    sz = size(features{k}(randn(N,1)));
    aa = toc;
    fprintf('OK (%.2fs) (size [%d,%d])\n',aa,sz(1),sz(2));
end

db = prepare_database(src,features);
db.features = single(db.features);
db = svm_calc_kernel(db,'gaussian','square',1:2:size(db.features,2));

partitions = load('prts-gtzan.mat');
train_set = partitions.prt_train;
test_set = partitions.prt_test;

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
