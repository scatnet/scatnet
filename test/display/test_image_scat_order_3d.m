clear
x = uiuc_sample;
x = x(1:256, 1:256);

%% compute the roto-translation scattering
Wop = wavelet_factory_3d(size(x));
Sx = scat(x, Wop);

%% display scattering S
var_y{1}.name = 'j';
var_y{1}.index = 1;
var_y{2}.name = 'j';
var_y{2}.index = 2;
var_x{1}.name = 'k2';
var_x{1}.index = 1;
var_x{2}.name = 'theta2';
var_x{2}.index = 1;

big_img = image_scat_layer_order(Sx{3},var_x, var_y,1);
imagesc(big_img)
ylabel('j_1, j_2');
xlabel('k_2, \theta_2');
