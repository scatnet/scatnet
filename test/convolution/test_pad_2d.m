clear; close all;
x = lena;
x = meshgrid(1:500, 1:500);
profile on;
for i = 1:100
    margin = [100, 100];
    x_old = pad_mirror_2d_twosided(x, margin);
    x_new = pad_signal(x, size(x) + 2*margin, [], 1);
	xp = unpad_signal(x_new, 0, size(x), 1);
	assert(norm(xp-x)<1e-14);
	x_new = pad_signal(x, size(x) + 2*margin, [], 0);
	x_new = x_new(1:2:end,1:2:end);
	xp = unpad_signal(x_new, 1, size(x), 0);
	assert(norm(xp-x(1:2:end,1:2:end))<1e-14);
end
profile off;
profile viewer;

subplot(121);
imagesc(x_old);
subplot(122);
imagesc(x_new);