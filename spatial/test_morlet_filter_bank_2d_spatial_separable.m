options.P = 3;
filters = morlet_filter_bank_2d_spatial_separable(options);

filt = filters.h.filter;
x = lena;

tic;
for k = 1:10
xfilt = convsub2d_spatial(x, filt, 0);
end
toc;