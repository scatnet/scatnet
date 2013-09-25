clear;

x = uiuc_sample;
x2 = rot90(x);

options.J = 5;
options.precision = 'single';
tic;
[Wop,f1,f2] = wavelet_factory_3d_spatial(options, options, options);
toc;
tic;
[Sx, Ux] = scat(x, Wop);
toc;
tic;
[Sx2, Ux2] = scat(x2, Wop);
toc;

%%
sx = format_scat(Sx);
sx2 = format_scat(Sx2);

ssx = sum(sum(sx,2),3);
ssx2 = sum(sum(sx2,2),3);
plot(log([ssx,ssx2]));
legend('original', 'rotated');
