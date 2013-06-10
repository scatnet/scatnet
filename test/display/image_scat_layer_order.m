x = uiuc_sample;
x = x(1:256, 1:256);

%% compute roto-translaiton scattering
filt_opt.J = 4;
filt_rot_opt.null = 1;
scat_opt.oversampling = 0;
Wop = wavelet_factory_3d(size(x), filt_opt, filt_rot_opt, scat_opt);

tic;
S_rt = scat(x, Wop);
toc;

%% arrange scattering layer in lexicographic order
var_y{1}.name = 'j';
var_y{1}.index = 1;
var_y{2}.name = 'j';
var_y{2}.index = 2;
var_x{1}.name = 'k2';
var_x{1}.index = 1;
var_x{2}.name = 'theta2';
var_x{2}.index = 1;

big_img = image_scat_layer_order(S_rt{3},var_x, var_y,0);
figure(2);
imagesc(big_img);
