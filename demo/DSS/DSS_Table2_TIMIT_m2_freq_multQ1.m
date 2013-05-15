% M=2 scattering + freq scatt, mult Q1, cv parameters

%run_name = 'phones_309';
run_name = 'DSS_Table2_TIMIT_m2_freq_multQ1';

src = phone_src('/home/anden/timit/TIMIT');

[prt_train,prt_test,prt_dev] = phone_partition(src);

N = 2^13;
T_s = 2560;

filt1_opt.filter_type = {'gabor_1d','morlet_1d'};
filt1_opt.Q = [8 1];
filt1_opt.J = T_to_J(512,filt1_opt.Q);

sc1_opt = struct();

ffilt1_opt.filter_type = 'morlet_1d';
ffilt1_opt.J = 6;

fsc1_opt = struct();

cascade1 = wavelet_factory_1d(N, filt1_opt, sc1_opt, 2);
fcascade1 = wavelet_factory_1d(64, ffilt1_opt, fsc1_opt, 1); 

scatt_fun1 = @(x)(log_scat(renorm_scat(scat(x,cascade1))));
fscatt_fun1 = @(x)(func_output(@scat_freq,2,scatt_fun1(x),fcascade1));
format_fun1 = @(x)(permute(format_scat(fscatt_fun1(x)),[3 1 2]));
feature_fun1 = @(x,obj)(feature_wrapper(x,obj,format_fun1,N,T_s,2,1));

filt2_opt = filt1_opt;
filt2_opt.Q = [1 1];
filt2_opt.J = T_to_J(512,filt2_opt.Q);

sc2_opt = sc1_opt;

ffilt2_opt = ffilt1_opt;
ffilt2_opt.J = 4;

fsc2_opt = fsc1_opt;

cascade2 = wavelet_factory_1d(N, filt2_opt, sc2_opt, 2);
fcascade2 = wavelet_factory_1d(16, ffilt2_opt, fsc2_opt, 1); 

scatt_fun2 = @(x)(log_scat(renorm_scat(scat(x,cascade2))));
fscatt_fun2 = @(x)(func_output(@scat_freq,2,scatt_fun2(x),fcascade2));
format_fun2 = @(x)(permute(format_scat(fscatt_fun2(x)),[3 1 2]));
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

%matlabpool 8

db = prepare_database(src,features);

db.features = single(db.features);

db = svm_calc_kernel(db,'gaussian','triangle');

addpath('~/cpp/libsvm-dense-compact-3.12/matlab');

optt.kernel_type = 'gaussian';
optt.gamma = 2.^[-14:2:-10];
optt.C = 2.^[2:2:6];
optt.search_depth = 2;

[dev_err_grid,C_grid,gamma_grid] = svm_adaptive_param_search(db,prt_train,prt_dev,optt);

[dev_err,ind] = min(dev_err_grid{end});
C = C_grid{end}(ind);
gamma = gamma_grid{end}(ind);

optt1 = optt;
optt1.C = C;
optt1.gamma = gamma;

model = svm_train(db,prt_train,optt1);
labels = svm_test(db,model,prt_test);
err = classif_err(labels,prt_test,db.src);
			
save([run_name '.mat'],'err','C','gamma');

