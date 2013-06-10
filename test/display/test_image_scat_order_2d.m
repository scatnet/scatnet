clear;
x = uiuc_sample;
x = x(1:256, 1:256);
%% compute the scattering
Wop = wavelet_factory_2d(size(x));
[Sx, U] = scat(x, Wop);

%% display scattering S
var_y{1}.name = 'j';
var_y{1}.index = 1;
var_y{2}.name = 'j';
var_y{2}.index = 2;
var_x{1}.name = 'theta';
var_x{1}.index = 1;
var_x{2}.name = 'theta';
var_x{2}.index = 2;


image_scat_layer_order(Sx{3},var_x, var_y,1);
ylabel('j_1, j_2');
xlabel('\theta_1, \theta_2');