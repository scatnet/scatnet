
N1=2^16; % we are working with 2 seconds frames.

N2=2^12;
db_path='envsounds/solosDbdb/o2_scat/';
T=2^12; %128 ms for fs= 32 KHz
order=2;
Q1=1;
Q2=1;


%set the filters options
filt1_opt.filter_type = {'gabor_1d','morlet_1d'};
filt1_opt.Q = [Q1 Q2];
filt1_opt.J = T_to_J(T,filt1_opt);


% set the scattering options
sc1_opt.M=2;
sc1_opt.use_abs=1; %used in wavelet_1d, preparing for renormalization with conv(abs(x),phi)

%Create the renormalization operator
Wop1=normalize_wavelet_factory_1d(N1,filt1_opt,sc1_opt);

scatt_fun1 = @(x)(scat(x,Wop1));
feature_fun1={@(x)(format_scat(aggregate_scat(scatt_fun1(x),T)))};
[~,meta]=feature_fun1{1}(rand(N1,1));

src=instsnds_src_multi_obj('envsounds/sDbCoVl',N1);

prep_opt.parallel=1;
prep_opt.average=1;
prep_opt.sig_normalize=1;

db1=prepare_inst_db(src,feature_fun1,prep_opt);
db1.features=single(db1.features);

sigmas=threshold_parameters_factory(db1,meta,'median');
save([db_path 'sigmas_sDbCoVl_T12_Q11.mat'],'sigmas');

%%%sigmas=load('sigmas_sDbCoVl_T12_Q11.mat'); sigmas=sigmas.sigmas;
clear db1;




thresholds=[0 1e-5 1e-4 1e-3 1e-2 1e-1 1 2 3];

lgth=length(thresholds);

all_recog_rates={};
all_recog=zeros(size(thresholds));

for l=1:lgth
    
    
    sc1_opt.threshold=thresholds(l);
    sc1_opt.sigmas=sigmas;
    sc1_
    
    %Prepare the normalizing standardizing and thresholding operator
    Wop2=normalize_standardize_threshold_wavelet_factory_1d(N1,filt1_opt,sc1_opt);

    scatt_fun2=@(X)(format_scat(scat(X,Wop2)));
    
    feature_fun={@(X)(scatt_fun2(X))};
    
    [~ ,meta]=feature_fun{1}(rand(N1,1));
    
    db=prepare_inst_db(src,feature_fun,prep_opt);
    db.features=single(db.features);
    
    
    %%Remove silent frames;
%     if ~isfield(db.src,'rejects')
%         db.src=filter_src(db.src);
%     end
    
    db=poor_whiten2(db);
    
    db=svm_calc_kernel(db,'gaussian','square',1:size(db.features,2));
    
    partitions = load('sDbCoVl_fparts.mat');
    
    files_train=partitions.files_train;
    files_test=partitions.files_test;
    
    [train_set ,test_set]= create_filt_feats_parts(db.src, files_train,files_test,[],[]);
    
    optt.kernel_type = 'gaussian';
    
    optt.C=2^16;
    optt.gamma=2^(-8);
    
    % The data is unbalanced, use weights
    optt.w=1;
    
    
    labels={};
    feature_lbls={};
    votes={};
    
    C=optt.C;
    gamma=optt.gamma;
    
    optt1 = optt;
    
    
    model = svm_train(db,train_set,optt1,db_weights);
    [labels votes feature_lbls] = svm_test(db,model,test_set);
    
    [recog recog_rates]=classif_recog(labels,test_set,db.src)
    err = 1-recog;
   
    all_recog_rates{l}=recog_rates;
    all_recog(l)=recog;
end

save('all_recog_rates_sDbCoVl.mat','all_recog_rates','all_recog','thresholds');
sendmail('michelkapoko@gmail.com','take this best cf','check',{'all_recog_rates_sDbCoVl.mat'});









