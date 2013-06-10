x = uiuc_sample;
x = x(1:256, 1:256);



%% morlet angle

filt_opt.J = 4;
filt_rot_opt.null = 1;
scat_opt.oversampling = 10;
Wop = wavelet_factory_3d(size(x), filt_opt, filt_rot_opt, scat_opt);

tic;
S_rt = scat(x, Wop);
toc;


big_img = image_scat_layer_order(S_rt{3},var_x, var_y,0);
figure(2);
imagesc(big_img);
