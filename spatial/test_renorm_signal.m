clear;
x = lena;

filters = morlet_filter_bank_2d_pyramid;
%%
tic;
[x_rn, tmp] = renorm_signal(x, filters.h.filter, 100);
toc;

imagesc(x_rn);
