
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

feature_fun1=@(x)(inter_normalize_scat(inter_normalize_scat(scatt_fun2(x),scatt_fun3(x),2),scatt_fun1(x),1));

src=instsnds_sigma_src_multi_obj('envsounds/solosDbf',N1);

prep_opt.parallel=1;

prep_opt.average=1;
prep_opt.sig_normalize=1;

sigmas=threshold_parameters_factory(feature_fun1,src,'median',prep_opt);





