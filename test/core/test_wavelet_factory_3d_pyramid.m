clear; close all;
x = uiuc_sample;
%%
scat_opt = struct();
filt_opt = struct();
filt_rot_opt = struct();
filt_opt.Q = 1;
scat_opt.J = 3;
filt_opt.precision = 'single';
tic;
[Wop,f1,f2] = wavelet_factory_3d_pyramid(filt_opt, filt_rot_opt, scat_opt);
toc;
tic;
[Sx, Ux] = scat(x, Wop);
toc;
%%
scat_opt = struct();
filt_opt = struct();
filt_rot_opt = struct();
filt_opt.Q = 1;
filt_opt.J = 3;
tic;

Wop2 = wavelet_factory_3d(size(x), filt_opt, filt_rot_opt, scat_opt);
toc;
tic;
[Sx2, Ux2] = scat(x, Wop2);
toc;


%%
sx = format_scat(Sx);
sx2 = format_scat(Sx2);

ssx = sum(sum(sx,3),2);
ssx2 = sum(sum(sx2,3),2);
plot([ssx, ssx2]);
plot(log([ssx, ssx2]));
legend('vanilla', 'spatial');

%%
immac(image_scat_layer(Sx{2}, 0, 0),1);
immac(image_scat_layer(Sx2{2}, 0, 0),2);

%%
immac(image_scat_layer(Sx{3}, 0, 0),1);
%%
immac(image_scat_layer(Sx2{3}, 0, 0),2);

