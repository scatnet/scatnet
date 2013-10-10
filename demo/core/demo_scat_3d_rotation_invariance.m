%% demonstrates the rotation invariance of the roto-translation scattering
clear; close all;
x = lena;
x = x(128:128+255, 128:128+255);

filt_opt = struct();
filt_rot_opt = struct();
% oversampling is set to infty
% so that scattering of original and rotated
% image will be sampled at exactly the same points
scat_opt.oversampling = 10;

Wop = wavelet_factory_3d(size(x), filt_opt, filt_rot_opt, scat_opt);

%% compute scattering of x
Sx = scat(x, Wop);
sx = format_scat(Sx);

%% compute scattering of x rotated by pi/2
x_rot = rot90(x,1);
Sx_rot = scat(x_rot, Wop);

%% rotate back the scattering of the rotated image
Sx_rot_back = scatfun(@(x)(rot90(x,3)), Sx_rot);
sx_rot_back = format_scat(Sx_rot_back);

%% display the third layer of scattering and back-rotated scattering of rotated image
subplot(121);
image_scat_layer(Sx{3},0,0);
subplot(122);
image_scat_layer(Sx_rot_back{3},0,0);

%% compute norm ratio
norm_diff = sqrt(sum((sx(:)-sx_rot_back(:)).^2));
norm_s = sqrt(sum((sx(:)).^2));
fprintf('\n ratio of norm difference vs norm %.10f ', norm_diff/norm_s);
