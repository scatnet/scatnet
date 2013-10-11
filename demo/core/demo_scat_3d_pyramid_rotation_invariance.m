%% a script that demonstrates the invariance of the roto-translation 
% scattering computed with the fast pyramid algorithm
clear; close all;

%% load an image
x = lena;

%% compute scattering
Wop = wavelet_factory_3d_pyramid();
Sx = scat(x, Wop);

%% compute scattering of rotated image
x_rot = rot90(x);
Sx_rot = scat(x_rot, Wop);

%% rotate back scattering coefficients
Sx_rot_back = scatfun(@(x)(rot90(x,3)), Sx_rot);

%% display original scattering and rotated-back scattering of rotated image
%% order 1
subplot(121);
image_scat_layer(Sx{2}, 0, 0);
subplot(122);
image_scat_layer(Sx_rot_back{2}, 0, 0);

%% order 2
subplot(121);
image_scat_layer(Sx{3}, 0, 0);
subplot(122);
image_scat_layer(Sx_rot_back{3}, 0, 0);

%% compute norm ratio
sx = format_scat(Sx);
sx_rot_back = format_scat(Sx_rot_back);
norm_diff = sqrt(sum((sx(:)-sx_rot_back(:)).^2));
norm_s = sqrt(sum((sx(:)).^2));
fprintf('\n ratio of norm difference vs norm %.10f ', norm_diff/norm_s);
% it is only approximately the same thing because the scattering of the original
% image and the scattering of the rotated image are not sampled on the
% exact same grid
% for perfect equality one must use the FFT-based implementation of 
% roto-translation scattering that allows oversampling
% see demo_scat_3d_rotation_invariance.m for a complete invariance demo