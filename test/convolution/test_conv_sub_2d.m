% this script 
% 1 - evaluates speedup of convolution and subsampling with periodization
%   before ifft over naive method
% 2 - verifies that the fast and naive approach give same results
x = uiuc_sample;

size_in = size(x);

filt_opt.margins = [0, 0];

filters = morlet_filter_bank_2d(size_in, filt_opt);

psif = filters.psi.filter{32}.coefft{1};
%% convolution then subsampling
ds = 3;
N = 100;
xf = fft2(x);
tic;
for i = 1:N
  tmp = abs(ifft2(xf .* psif));
  xconvpsi = tmp(1:2^ds:end, 1:2^ds:end)*2^ds;
end
toc;

%% periodization before ifft : 2-3 times faster
tic;
for i = 1:N
  xconvpsi_fast = abs(conv_sub_unpad_2d(xf, psif, ds,[0,0]));
end
toc;

imagesc([xconvpsi,xconvpsi_fast])
norm(xconvpsi(:) - xconvpsi_fast(:)) 