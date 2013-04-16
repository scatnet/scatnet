% this script 
% 1 - evaluates speedup of convolution and subsampling with periodization
%   before ifft over naive method
% 2 - verifies that the fast and naive approach give same results
x = uiuc_sample;

size_in = size(x);

filters = morlet_filter_bank_2d(size_in);

psif = filters.psi.filter{32}.coefft{1};
%% convolution then subsampling
ds = 3;
N = 100;
xf = fft2(x);
tic;
for i = 1:N
  tmp = abs(ifft2(xf .* psif));
  xconvpsi = tmp(1:2^ds:end, 1:2^ds:end)*2^(2*ds);
end
toc;

%% periodization before ifft : 2-3 times faster
tic;
for i = 1:N
  xconvpsi_fast = abs(conv_sub_2d(xf, psif, ds));
end
toc;

imagesc([xconvpsi,xconvpsi_fast])
assert(norm(xconvpsi(:) - xconvpsi_fast(:)) < 1E-13);