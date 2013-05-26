% this scripts makes comparaison of L1/L2 norm ratio for 
% translation scattering and roto-translation scattering

clear;
N = 128;

%% grid
x = zeros(N,N);
step_grid = 16;
for i = 1:step_grid:N
	x(:,i) = 1;
	x(i,:) = 1;
end
%% square
x = zeros(N,N);
pad = N/4;
x(pad,pad:N-pad) = 1;
x(N-pad,pad:N-pad) = 1;
x = x';
x(pad,pad:N-pad) = 1;
x(N-pad,pad:N-pad) = 1;
imagesc(x);
%% circle
radius = N/3;
sigma_radius = 1;
x = draw_circle([N,N], [N/2, N/2], radius, sigma_radius);
imagesc(x);

%% define scattering options
options.antialiasing = 10;
options.J = 4;

%% translation scattering
tic;
W_trans = wavelet_factory_2d(size(x),options);
S_trans = scat(x, W_trans);
toc;

%% roto-translation scattering
tic;
W_rt = wavelet_factory_3d(size(x),options);
S_rt = scat(x, W_rt);
toc;


%% roto-translation scattering with meyer wavelet along the angle
options.null = 1;
options_rot.meyer_rot = 1;
tic;
[W_rt_meyer,f2, f3] = wavelet_factory_3d(size(x), options, options_rot);

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


%% order 3 only
So3_rt = cell2mat(S_rt{3}.signal);
So3_rt_meyer = cell2mat(S_rt_meyer{3}.signal);


%% histogram of log values
clf;
subplot(311);
hist(log(S_trans_f(:)+0.0001),100);
subplot(312);
hist(log(S_rt_f(:)+0.0001),100);
subplot(313);
hist(log(S_rt_meyer_f(:)+0.0001),100);

%%
clf;
subplot(121);
imagesc([image_scat_layer(S_trans{3},0,0)]);


var_y{1}.name = 'j';
var_y{1}.index = 1;
var_y{2}.name = 'j';
var_y{2}.index = 2;

var_x{1}.name = 'theta';
var_x{1}.index = 1;
var_x{2}.name = 'theta';
var_x{2}.index = 2;
tmp0=image_scat_layer_order(S_trans{3},var_x,var_y,0);
imagesc(tmp0)
immac(tmp0)

%%

subplot(122);
%imagesc([image_scat_layer(S_rt{3},1,0),image_scat_layer(S_rt_meyer{3},0,0)]);

imagesc([image_scat_layer(S_rt{3},0,0),image_scat_layer(S_rt_meyer{3},0,0)]);


var_y{1}.name = 'j';
var_y{1}.index = 1;
var_y{2}.name = 'j';
var_y{2}.index = 2;

var_x{1}.name = 'k2';
var_x{1}.index = 1;
var_x{2}.name = 'theta2';
var_x{2}.index = 1;

%tmp = [image_scat_layer(S_rt{3},0,0),image_scat_layer(S_rt_meyer{3},0,0)];
tmp = image_scat_layer_order(S_rt{3},var_x, var_y,0);
tmp2 = image_scat_layer_order(S_rt_meyer{3},var_x, var_y,0);

%imagesc([tmp, tmp2]);
immac([tmp; tmp2]);
%image_scat_layer(S_rt_meyer{3},0,0)]);
