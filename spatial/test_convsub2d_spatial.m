options.P = 3;
filters = morlet_filter_bank_2d_spatial(options);
filters_sep = morlet_filter_bank_2d_spatial_separable(options);
x = lena;
x = single(x);

filter = filters.h.filter;
x_h = convsub2d_spatial(x, filter, 1);
filter = filters.g.filter{5};
x_g = convsub2d_spatial(x, filter, 0);
subplot(121);
imagesc(x_h);
subplot(122);
imagesc(abs(x_g));


%% speed fft vs spatial vs spatial separable
filter = filters.g.filter{4};
filter_sep = filters_sep.g.filter{4};
hc = filter.coefft;


psi = zeros(size(x));
psi(1:size(hc,1),1:size(hc,2)) = hc;
xf = fft2(x);
psif = fft2(psi);
tic;
for k = 1:10
	xpsif = ifft2(xf .* psif);
end
toc;
tic;
for k = 1:10
	xpsi = convsub2d_spatial(x, filter, 0);
end
toc;

tic;
for k = 1:10
	xpsi_sep = convsub2d_spatial(x, filter_sep, 0);
end
toc;
subplot(131);
imagesc(abs(xpsif));
subplot(132);
imagesc(abs(xpsi));
subplot(133);
imagesc(abs(xpsi_sep));

%%

tic; 
P = 4;
h = rand(2*P+1, 2*P+1);
h1 = rand(1, 2*P+1);
h2 = rand(1, 2*P+1)';



tic;
for k = 1:100
	conv2(x,h);
end
toc;

tic;
for k = 1:100
	conv2(h1,h2,x);
end
toc;