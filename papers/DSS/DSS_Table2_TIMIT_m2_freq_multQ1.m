% M=2 scattering + freq scatt, mult Q1, cv parameters

run_name = 'DSS_Table2_TIMIT_m2_freq_multQ1';

src = phone_src('/home/anden/timit/TIMIT');

[train_set,test_set,valid_set] = phone_partition(src);

N = 2^13;
T_s = 2560;

filt1_opt.filter_type = {'gabor_1d','morlet_1d'};
filt1_opt.Q = [8 1];
filt1_opt.J = T_to_J(512,filt1_opt.Q);

sc1_opt.M = 2;

ffilt1_opt.filter_type = 'morlet_1d';
ffilt1_opt.J = 6;

fsc1_opt.M = 1;

Wop1 = wavelet_factory_1d(N, filt1_opt, sc1_opt);
fWop1 = wavelet_factory_1d(64, ffilt1_opt, fsc1_opt); 

scatt_fun1 = @(x)(log_scat(renorm_scat(scat(x,Wop1))));
fscatt_fun1 = @(x)(func_output(@scat_freq,2,scatt_fun1(x),fWop1));
format_fun1 = @(x)(format_scat(fscatt_fun1(x)));
feature_fun1 = @(x,obj)(feature_wrapper(x,obj,format_fun1,N,T_s,2,1));

filt2_opt = filt1_opt;
filt2_opt.Q = [1 1];
filt2_opt.J = T_to_J(512,filt2_opt.Q);

sc2_opt = sc1_opt;

ffilt2_opt = ffilt1_opt;
ffilt2_opt.J = 4;

fsc2_opt = fsc1_opt;

Wop2 = wavelet_factory_1d(N, filt2_opt, sc2_opt);
fWop2 = wavelet_factory_1d(16, ffilt2_opt, fsc2_opt); 

scatt_fun2 = @(x)(log_scat(renorm_scat(scat(x,Wop2))));
fscatt_fun2 = @(x)(func_output(@scat_freq,2,scatt_fun2(x),fWop2));
format_fun2 = @(x)(format_scat(fscatt_fun2(x)));
feature_fun2 = @(x,obj)(feature_wrapper(x,obj,format_fun2,N,T_s,2,1));

duration_fun = @(x,obj)(32*duration_feature(x,obj));

features = {feature_fun1, feature_fun2, duration_fun};

for k = 1:length(features)
    fprintf('testing feature #%d...',k);
    tic;
    sz = size(features{k}(randn(N,1),struct('u1',1,'u2',N)));
    aa = toc;
    fprintf('OK (%.2fs) (size [%d,%d])\n',aa,sz(1),sz(2));
end

db = prepare_database(src,features);
db.features = single(db.features);
db = svm_calc_kernel(db,'gaussian','triangle');

optt.kernel_type = 'gaussian';
optt.gamma = 2.^[-14:2:-10];
optt.C = 2.^[2:2:6];
optt.search_depth = 2;

[dev_err_grid,C_grid,gamma_grid] = ...
	svm_adaptive_param_search(db,train_set,valid_set,optt);

[dev_err,ind] = min(dev_err_grid{end});
C = C_grid{end}(ind);
gamma = gamma_grid{end}(ind);

optt1 = optt;
optt1.C = C;
optt1.gamma = gamma;

model = svm_train(db,train_set,optt1);
labels = svm_test(db,model,test_set);
err = classif_err(labels,test_set,db.src);
			
save([run_name '.mat'],'err','C','gamma');

