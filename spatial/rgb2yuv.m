function x_yuv = rgb2yuv(x_rgb)
r = x_rgb(:,:,1);
g = x_rgb(:,:,2);
b = x_rgb(:,:,3);
wr = 0.2126;
wb = 0.0722;
wg = 1-wr-wb;
umax = 0.436;
vmax = 0.615;
Y = wr*r +wg*g+wb*b;
x_yuv(:,:,1) = Y;
x_yuv(:,:,2) = umax*((b-Y)/(1-wb));
x_yuv(:,:,3) = vmax* ((r-Y)/(1-wr));
end