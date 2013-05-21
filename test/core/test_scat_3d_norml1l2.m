% this scripts makes comparaison of L1/L2 norm ratio for 
% translation scattering and roto-translation scattering

clear;
N = 512;

x = zeros(N,N);
step_grid = 16;
for i = 1:step_grid:N
	x(:,i) = 1;
	x(i,:) = 1;
end
%%
N = 256;
x = zeros(N,N);
pad = 64;
x(pad,pad:N-pad) = 1;
x(N-pad,pad:N-pad) = 1;
x = x';
x(pad,pad:N-pad) = 1;
x(N-pad,pad:N-pad) = 1;
imagesc(x);

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


%% roto-translation scattering with meyer wavelet along the angle
options.null = 1;
options_rot.meyer_rot = 1;
tic;
W_rt_meyer = wavelet_factory_3d(size(x), options, options_rot);
S_rt_meyer = scat(x, W_rt_meyer);
toc;

%% format 
S_trans_f = format_scat(S_trans);
S_rt_f = format_scat(S_rt);
S_rt_meyer_f = format_scat(S_rt_meyer);

%% norm l2 comparaison
x_l2 = sqrt(sum(x(:).^2))
S_trans_l2 = sqrt(sum(S_trans_f(:).^2))
S_rt_l2 = sqrt(sum(S_rt_f(:).^2))
S_rt_meyer_l2 = sqrt(sum(S_rt_meyer_f(:).^2))

%% norm l1 comparaison
x_l1 = sum(abs(x(:)))
S_trans_l1 = sum(abs(S_trans_f(:)))
S_rt_l1 = sum(abs(S_rt_f(:)))
S_rt_meyer_l1 = sum(abs(S_rt_meyer_f(:)))

%% histogram of log values
clf;
subplot(311);
hist(log(S_trans_f(:)+0.0001),10);
subplot(312);
hist(log(S_rt_f(:)+0.0001),10);
subplot(313);
hist(log(S_rt_meyer_f(:)+0.0001),10);
