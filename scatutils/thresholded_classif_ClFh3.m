% 
% 
% N1=2^16; % we are working with 2 seconds frames.
% 
% N2=2^12;
% db_path='envsounds/solosDbdb/o2_scat/';
% T=2^12; %128 ms for fs= 32 KHz
% order=2;
% Q1=1;
% Q2=1;
% 
% 
% 
% filt1_opt.filter_type = {'gabor_1d','morlet_1d'};
% filt1_opt.Q = [Q1 Q2];
% filt1_opt.J = T_to_J(T,filt1_opt); %371.5 ms
% 
% %% set the scattering options
% sc1_opt = struct();
% sc1_opt.M=1;
% 
% Wop1=wavelet_factory_1d(N1,filt1_opt,sc1_opt);
% 
% scatt_fun1 = @(x)(scat(abs(x),Wop1));
% 
% filt2_opt=filt1_opt;
% sc2_opt.M = 2;
% 
% sc2_opt.oversampling=1;
% 
% Wop2 = wavelet_factory_1d(N1, filt2_opt, sc2_opt);
% scatt_fun2= @(x)(func_output(@scat,2,x,Wop2));
% scatt_fun3= @(x)(scat(x,Wop1));
% 
% scatt_fun4=@(x)(inter_normalize_scat(...
%     inter_normalize_scat(...
%     scatt_fun2(x),scatt_fun3(x),2),scatt_fun1(x),1));
% 
% 
% feature_fun1={@(x)(format_scat(aggregate_scat(scatt_fun4(x),T)))};
%  [~,meta]=feature_fun1{1}(rand(N1,1));
% 
% 
% %%%sigma_src=instsnds_sigma_src_multi_obj('envsounds/sDbClFh',N1);
% 
% src=instsnds_src_multi_obj('envsounds/sDbClFh',N1);
% 
% prep_opt.parallel=1;
% prep_opt.average=1;
% prep_opt.sig_normalize=1;
% 
% db1=prepare_inst_db(src,feature_fun1,prep_opt);
% db1.features=single(db1.features);
% 
sigmas=threshold_parameters_factory(db1,meta,'median');
save([db_path 'sigmas_sDbClFh_T12_Q11.mat'],'sigmas');

feature_fun2={@(x)(standardize_scat(scatt_fun4(x),sigmas))};

db2=prepare_wmt_database(src,feature_fun2,prep_opt);

save('sDbClFh_standardized_wmt.mat','db1')

src=filter_src(src);

thresholds=[0 1e-6 1e-5 1e-4 1e-3];
 
all_recog_rates={};
all_recog=zeros(size(thresholds));


for k=1:length(thresholds)
    
    feature_fun = {@(X)(format_scat(phi_scat(threshold_scat(X,thresholds(k)))))};
    db=prepare_inst_db(src,feature_fun,prep_opt);
    
%     if ~isfield(db.src,'rejects')
%         db.src=filter_src(db.src);
%     end
    
    % test the sigma normalization
    db=poor_whiten2(db);
    
    db=svm_calc_kernel(db,'gaussian','square',1:size(db.features,2));
    
    partitions = load('sDbClFh_fparts.mat');
    
    files_train=partitions.files_train;
    files_test=partitions.files_test;
    
    [train_set ,test_set]= create_filt_feats_parts(db.src,files_train,files_test,[],[]);
    
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
    % run_name=['envsounds/solosDbdb/o2_scat/sDbClFhmo12o2Q' num2str(Q1) num2str(Q2) '_sig' num2str(thresh1) '_thr_cw_filt_test']
    % save([run_name '_svm.mat'],'err','C','gamma','labels','votes','feature_lbls','recog','recog_rates');
    
    all_recog_rates{l}=recog_rates;
    all_recog(l)=recog;
    
    
end

save('all_recog_rates_sDbClFh.mat','all_recog_rates','all_recog','thresh');
sendmail('michelkapoko@gmail.com','take this best cf','check',{'all_recog_rates_sDbClFh.mat'})









