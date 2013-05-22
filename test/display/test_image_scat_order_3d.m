clear
x = lena;

%% compute the roto-translation scattering
W = wavelet_factory_3d(size(x));
S = scat(x, W);

%% display scattering S
var_y{1}.name = 'j';
var_y{1}.index = 1;
var_y{2}.name = 'j';
var_y{2}.index = 2;
var_x{1}.name = 'k2';
var_x{1}.index = 1;
var_x{2}.name = 'theta2';
var_x{2}.index = 1;

big_img = image_scat_layer_order(S{3},var_x, var_y,1);
imagesc(big_img)
ylabel('j_1, j_2');
xlabel('k_2, \theta_2');
