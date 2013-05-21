% this scripts makes comparaison of L1/L2 norm ratio for 
% translation scattering and roto-translation scattering

clear;
x = lena;

%% translation scattering
tic;
W_trans = wavelet_factory_2d(size(x));
S_trans = scat(x, W_trans);
toc;

%% roto-translation scattering
tic;
W_rt = wavelet_factory_3d(size(x));
S_rt = scat(x, W_rt);
toc;

%% format both
S_trans_f = format_scat(S_trans);
S_rt_f = format_scat(S_rt);

%% norm l2 comparaison
x_l2 = sqrt(sum(x(:).^2))
S_trans_l2 = sqrt(sum(S_trans_f(:).^2))
S_rt_l2 = sqrt(sum(S_rt_f(:).^2))

%% norm l1 comparaison
x_l1 = sum(abs(x(:)))
S_transl_l1 = sum(abs(S_trans_f(:)))
S_rt_l1 = sum(abs(S_rt_f(:)))