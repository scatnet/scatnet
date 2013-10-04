filt_opt.J = 3;
filters1d = morlet_filter_bank_1d(32, filt_opt);
w_opt.oversampling = 100;

x = real([1:32]==16)';

x_phi = wavelet_1d(x, filters1d, w_opt);

rl_opt.rl_iter = 8192;

x1 = richardson_lucy(pad_signal(x_phi,64), filters1d.phi.filter, rl_opt);

assert(norm(x-unpad_signal(x1,0,32))<1e-2);

x_phi = x_phi(1:4:end)*sqrt(4);

x1 = richardson_lucy(max(upsample(pad_signal(x_phi,16),64),0), filters1d.phi.filter, rl_opt);
	
assert(norm(x-unpad_signal(x1,0,32))<0.5);