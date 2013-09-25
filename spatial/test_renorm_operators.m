clear;
x = lena;
options.J = 3;
[Wop, filters] = wavelet_factory_3d_pyramid;
h = filters.h.filter;
K = 1;
tic;
Woprn = renorm_operators(Wop, h, K, 'iterate');
toc;
[sxrnNew, uxrnNew] = scat(x, Woprn);



image_scat(sxrnNew,0,0);
%%
[sx, ux ] = scat(x, Wop);

sxrnOld = renorm_scat_spatial(sx);
image_scat(sxrnOld,0,0);
%%
image_scat(sx,0,0);
