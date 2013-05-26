clear;
x = lena;

%% compute the scattering
W = wavelet_factory_2d(size(x));
[S, U] = scat(x, W);

%% display scattering S
var_y{1}.name = 'j';
var_y{1}.index = 1;
var_y{2}.name = 'j';
var_y{2}.index = 2;
var_x{1}.name = 'theta';
var_x{1}.index = 1;
var_x{2}.name = 'theta';
var_x{2}.index = 2;


big_img = image_scat_layer_order(S{3},var_x, var_y,1);
imagesc(big_img)
ylabel('j_1, j_2');
xlabel('\theta_1, \theta_2');