%run_name = 'gtzan_201';

tic
run_name = 'DSS_Table2_GTZAN_m2_freq_multQ1';

src = gtzan_src('~/GTZAN/gtzan');


N = 5*2^17;



filt1_opt.filter_type = {'gabor_1d','morlet_1d'};
filt1_opt.Q = [8 1];
filt1_opt.J = T_to_J(8192,filt1_opt.Q);

sc1_opt=struct();
ffilt1_opt.filter_type = 'morlet_1d';
ffilt1_opt.J = 7;


fsc1_opt=struct();


cascade1 = wavelet_factory_1d(N, filt1_opt, sc1_opt, 2);
fcascade1 = wavelet_factory_1d(128, ffilt1_opt,fsc1_opt, 1);

scatt_fun1 = @(x)(log_scat(renorm_scat(scat(x,cascade1))));
% [~,U] = scat_freq(scat_fun(x),fcascade);
% return U
fscatt_fun1 = @(x)(func_output(@scat_freq,2,scatt_fun1(x),fcascade1));
feature_fun1 = @(x)(squeeze(format_scat(fscatt_fun1(x))));

filt2_opt = filt1_opt;
filt2_opt.Q = [1 1];
filt2_opt.J = T_to_J(8192,filt2_opt.Q);

sc2_opt = sc1_opt;

ffilt2_opt = ffilt1_opt;
ffilt2_opt.J = 5; %For the momen I don't know how to choose the right 
%value for J

fsc2_opt = fsc1_opt;

cascade2 = wavelet_factory_1d(N, filt2_opt, sc2_opt, 2);
fcascade2 = wavelet_factory_1d(32, ffilt2_opt, fsc2_opt, 1);% ici aussi, pas sure de la valeur
%utilisee pour N.

scatt_fun2 = @(x)(log_scat(renorm_scat(scat(x,cascade2))));
fscatt_fun2 = @(x)(func_output(@scat_freq,2,scatt_fun2(x),fcascade2));

feature_fun2 = @(x)(squeeze(format_scat(fscatt_fun2(x))));

features = {feature_fun1,feature_fun2};


for k = 1:length(features)
    fprintf('testing feature #%d...',k);
    tic;
    sz = size(features{k}(randn(N,1)));
    aa = toc;
    fprintf('OK (%.2fs) (size [%d,%d])\n',aa,sz(1),sz(2));
end


db = prepare_database(src,features,struct('feature_sampling',1));

db.features = single(db.features);

db = svm_calc_kernel(db,'gaussian','square',1:2:size(db.features,2));

load('~/matlab/scattlab1d/prts-gtzan.mat');

addpath('~/cpp/libsvm-dense-compact-3.12/matlab');

optt.kernel_type = 'gaussian';
optt.C = 2.^[0:4:8];
optt.gamma = 2.^[-16:4:-8];
optt.search_depth = 3;
optt.full_test_kernel = 0;

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



