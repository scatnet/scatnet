
N1=2^16; % we are working with 2 seconds frames.

filt1_opt.filter_type = {'gabor_1d','morlet_1d'};
filt1_opt.Q = [Q1 Q2];
filt1_opt.J = T_to_J(T,filt1_opt.Q); %371.5 ms

%% set the scattering options
sc1_opt = struct();
sc1_opt.M=1;

Wop1=wavelet_factory_1d(N1,filt1_opt,sc1_opt);

scatt_fun1 = @(x)(scat(abs(x),Wop1));

filt2_opt=filt1_opt;
sc2_opt.M = 2;

sc2_opt.oversampling=1;

Wop2 = wavelet_factory_1d(N1, filt1_opt, sc1_opt);
scatt_fun2= @(x)(func_output(scat,2,x,Wop2));
scatt_fun3= @(x)(scat(x,Wop1));

feature_fun1={@(x)(inter_normalize_scat(inter_normalize_scat(scatt_fun2(x),scatt_fun3(x),2),scatt_fun1(x),1))};

sigma_src=instsnds_sigma_src_multi_obj('envsounds/solosDbf',N1);

prep_opt.parallel=0;
prep_opt.average=1;
prep_opt.sig_normalize=1;

%sigmas=threshold_parameters_factory(feature_fun1,sigma_src,'median',prep_opt);

feature_fun2={@(x)(standardize_scat(feature_fun1{1}(x),sigmas))};

src=instsnds_src_multi_obj('envsounds/solosDbf',N1);

db1=prepare_wmt_database(src,feature_fun2,prep_opt);

save('sDbf_standardized_wmt.mat','db1')

% db=prepare_inst_db(src,feature_fun1,prep_opt);
% db.features=single(db.features);

src=filter_src(src);

thresholds=[1e-9 1e-8 1e-7];

for k=1:length(thresholds)
    
    feature_fun = {@(X)(format_scat(phi_scat(threshold_scat(X,thresholds(k)))))};
    db=prepare_inst_db(src,feature_fun,prep_opt);
    
    all_recog_rates={};
    all_recog=zeros(size(thresh));
    
    if ~isfield(db.src,'rejects')
        db.src=filter_src(db.src);
    end
    
    % test the sigma normalization
    db=poor_whiten2(db);
    
    db=svm_calc_kernel(db,'gaussian','square',1:20:size(db.features,2));
    
    partitions = load('sDbf_fparts.mat');
    
    files_train=partitions.files_train;
    files_test=partitions.files_test;
    
    [train_set ,test_set]= create_filt_feats_parts(db.src, files_train,files_test,[],db.src.rejects);
    
    optt.kernel_type = 'gaussian';
    
    optt.C=2^16;
    optt.gamma=2^(-8);
    
    
    db_weights = calc_train_weights(db,train_set);
    
    labels={};
    feature_lbls={};
    votes={};
    
    
    
    C=optt.C;
    gamma=optt.gamma;
    
    optt1 = optt;
    
    
    model = weighted_svm_train(db,train_set,optt1,db_weights);
    [labels votes feature_lbls] = svm_test(db,model,test_set);
    
    [recog recog_rates]=classif_recog(labels,test_set,db.src)
    err = 1-recog;
    
    
    % tend1=toc
    % run_name=['envsounds/solosDbdb/o2_scat/sDbfmo12o2Q' num2str(Q1) num2str(Q2) '_sig' num2str(thresh1) '_thr_cw_filt_test']
    % save([run_name '_svm.mat'],'err','C','gamma','labels','votes','feature_lbls','recog','recog_rates');
    
    all_recog_rates{l}=recog_rates;
    all_recog(l)=recog;
end

save('all_recog_rates_sDbf_best_cf2.mat','all_recog_rates','all_recog','thresh');
sendmail('michelkapoko@gmail.com','take this best cf','check',{'all_recog_rates_sDbf_best_cf2.mat'})









