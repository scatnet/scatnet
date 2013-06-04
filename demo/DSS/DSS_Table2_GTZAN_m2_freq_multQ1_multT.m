% M=2 scattering + freq scatt, mult Q1, mult T

run_name = 'DSS_Table2_GTZAN_m2_freq_multQ1_multT';
tic
src = gtzan_src('/home/anden/GTZAN/gtzan');

[prt_train,prt_test] = create_partition(src);

N = 5*2^17;

filt1_opt.filter_type = {'gabor_1d','morlet_1d'};
filt1_opt.Q = [8 1];
filt1_opt.J = T_to_J(8192,filt1_opt.Q);

sc1_opt = struct();

ffilt1_opt.filter_type = 'morlet_1d';
ffilt1_opt.J = 7;

fsc1_opt = struct();

cascade1 = wavelet_factory_1d(N, filt1_opt, sc1_opt, 2);
fcascade1 = wavelet_factory_1d(128, ffilt1_opt, fsc1_opt, 1);

scatt_fun1 = @(x)(log_scat(renorm_scat(scat(x,cascade1))));
fscatt_fun1 = @(x)(func_output(@scat_freq,2,scatt_fun1(x),fcascade1));
feature_fun1 = @(x)(squeeze(format_scat(fscatt_fun1(x))));

filt2_opt = filt1_opt;
filt2_opt.Q = [1 1];
filt2_opt.J = T_to_J(8192,filt2_opt.Q);

sc2_opt = sc1_opt;

ffilt2_opt = ffilt1_opt;
ffilt2_opt.J = 5;

fsc2_opt = fsc1_opt;

cascade2 = wavelet_factory_1d(N, filt2_opt, sc2_opt, 2);
fcascade2 = wavelet_factory_1d(32, ffilt2_opt, fsc2_opt, 1);

scatt_fun2 = @(x)(log_scat(renorm_scat(scat(x,cascade2))));
fscatt_fun2 = @(x)(func_output(@scat_freq,2,scatt_fun2(x),fcascade2));
feature_fun2 = @(x)(squeeze(format_scat(fscatt_fun2(x))));

filt3_opt = filt1_opt;
filt3_opt.J = T_to_J(2*8192,filt3_opt.Q);

sc3_opt = sc1_opt;

cascade3 = wavelet_factory_1d(N, filt3_opt, sc3_opt, 2);

scatt_fun3 = @(x)(log_scat(renorm_scat(scat(x,cascade3))));
fscatt_fun3 = @(x)(func_output(@scat_freq,2,scatt_fun3(x),fcascade1));
feature_fun3 = @(x)(squeeze(format_scat(fscatt_fun3(x))));

filt4_opt = filt2_opt;
filt4_opt.J = T_to_J(2*8192,filt4_opt.Q);

sc4_opt = sc2_opt;

cascade4 = wavelet_factory_1d(N, filt4_opt, sc4_opt, 2);

scatt_fun4 = @(x)(log_scat(renorm_scat(scat(x,cascade4))));
fscatt_fun4 = @(x)(func_output(@scat_freq,2,scatt_fun4(x),fcascade2));
feature_fun4 = @(x)(squeeze(format_scat(fscatt_fun4(x))));

filt5_opt = filt1_opt;
filt5_opt.J = T_to_J(4*8192,filt5_opt.Q);

sc5_opt = sc1_opt;

cascade5 = wavelet_factory_1d(N, filt5_opt, sc5_opt, 2);

scatt_fun5 = @(x)(log_scat(renorm_scat(scat(x,cascade5))));
fscatt_fun5 = @(x)(func_output(@scat_freq,2,scatt_fun5(x),fcascade1));
feature_fun5 = @(x)(squeeze(format_scat(fscatt_fun5(x))));

filt6_opt = filt2_opt;
filt6_opt.J = T_to_J(4*8192,filt6_opt.Q);

sc6_opt = sc2_opt;

cascade6 = wavelet_factory_1d(N, filt6_opt, sc6_opt, 2);

scatt_fun6 = @(x)(log_scat(renorm_scat(scat(x,cascade6))));
fscatt_fun6 = @(x)(func_output(@scat_freq,2,scatt_fun6(x),fcascade2));
feature_fun6 = @(x)(squeeze(format_scat(fscatt_fun6(x))));


features = {feature_fun1, feature_fun2, feature_fun3, feature_fun4, feature_fun5, feature_fun6};

for k = 1:length(features)
    fprintf('testing feature #%d...',k);
    tic;
    sz = size(features{k}(randn(N,1)));
    aa = toc;
    fprintf('OK (%.2fs) (size [%d,%d])\n',aa,sz(1),sz(2));
end

%matlabpool 8

    db = prepare_database(src,features);

db.features = single(db.features);

db = svm_calc_kernel(db,'gaussian','square',1:2:size(db.features,2));

addpath('~/cpp/libsvm-dense-compact-3.12/matlab');

optt.kernel_type = 'gaussian';
optt.C = 2.^[0:4:8];
optt.gamma = 2.^[-16:4:-8];
optt.search_depth = 3;
optt.full_test_kernel = 0;

[dev_err_grid,C_grid,gamma_grid] = svm_adaptive_param_search(db,prt_train,[],optt);

[dev_err,ind] = min(dev_err_grid{end});
C = C_grid{end}(ind);
gamma = gamma_grid{end}(ind);

optt1 = optt;
optt1.C = C;
optt1.gamma = gamma;

model = svm_train(db,prt_train,optt1);
labels = svm_test(db,model,prt_test);
err = classif_err(labels,prt_test,db.src);
toc
save([run_name '.mat'],'err','C','gamma');
