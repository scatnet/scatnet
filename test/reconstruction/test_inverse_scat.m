filt_opt.J = 3;
scat_opt.M = 2;

[Wop,filters] = wavelet_factory_1d(32, filt_opt, struct('M',2));

x = real([1:32]'==16);

[S,U] = scat(x,Wop);

xt = inverse_scat(S, filters, struct(), [0 1]); 
assert(norm(x-xt)/norm(x)<1e-1);

y = U{2}.signal{1};
yt = inverse_scat(S, filters, struct(), [1 1]); 
assert(norm(y-yt)/norm(y)<2e-1);

y = upsample(U{3}.signal{1},32);
yt = inverse_scat(S, filters, struct(), [2 1]);
assert(norm(y-yt)/norm(y)<1e-1);