


%%
N = 512;
x = lena;




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
