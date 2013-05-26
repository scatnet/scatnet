

N = 128;
radius = 32;
sigma_radius = 1;
x = draw_circle([N,N], [N/2, N/2], radius, sigma_radius);
imagesc(x);
pause(0.1);


options.null = 1;
%%
N = 512;
x = lena;

%% meyer angle

options.J = 4;
options.antialiasing = 1;
options_rot.meyer_rot = 1;
W_rt_meyer = wavelet_factory_3d([N,N], options, options_rot);

tic;
S_rt_meyer = scat(x, W_rt_meyer);
toc;



var_y{1}.name = 'j';
var_y{1}.index = 1;
var_y{2}.name = 'j';
var_y{2}.index = 2;

var_x{1}.name = 'k2';
var_x{1}.index = 1;
var_x{2}.name = 'theta2';
var_x{2}.index = 1;
%%
big_img = image_scat_layer_order(S_rt_meyer{3},var_x, var_y,1);
figure(1);
immac(big_img);



%% morlet angle

options.J = 4;
options.antialiasing = 10;
options_rot.meyer_rot = 0;
W_rt = wavelet_factory_3d([N,N], options, options_rot);

tic;
S_rt = scat(x, W_rt);
toc;


big_img = image_scat_layer_order(S_rt{3},var_x, var_y,0);
figure(2);
imagesc(big_img);
