% M=1 scattering, cv parameters

%run_name = 'phones_303';
run_name = 'DSS_Table2_TIMIT_m1';

src = phone_src('/home/anden/timit/TIMIT');

[train_set,test_set,valid_set] = phone_partition(src);

N = 2^13;
T_s = 2560;

filt1_opt.filter_type = {'gabor_1d','morlet_1d'};
filt1_opt.Q = [8 1];
filt1_opt.J = T_to_J(512,filt1_opt.Q);

sc1_opt = struct();

cascade = wavelet_factory_1d(N, filt1_opt, sc1_opt, 1);

scatt_fun = @(x)(permute(format_scat(log_scat(renorm_scat(scat(x,cascade)))),[3 1 2]));
feature_fun = @(x,obj)(feature_wrapper(x,obj,scatt_fun,N,T_s,2,1));

duration_fun = @(x,obj)(32*duration_feature(x,obj));

features = {feature_fun, duration_fun};

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

[dev_err_grid,C_grid,gamma_grid] = svm_adaptive_param_search(db,train_set,valid_set,optt);

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

