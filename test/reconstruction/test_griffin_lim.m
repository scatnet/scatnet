filt_opt.J = 3;
filters1d = morlet_filter_bank_1d(32, filt_opt);
w_opt.oversampling = 100;

x = real([1:32]==16)';

[x_phi,x_psi,meta_phi,meta_psi] = wavelet_1d(x, filters1d, w_opt);
x_psi_mod = cellfun(@abs, x_psi, 'UniformOutput',0);
x1 = griffin_lim(x_phi, x_phi, x_psi_mod, filters1d, w_opt);
assert(norm(x1-x)<1e-2)

rs = RandStream.create('mt19937ar','Seed',1234);
x1 = griffin_lim(rs.randn(32,1), x_phi, x_psi_mod, filters1d, w_opt);
assert(norm(x1-x)<1e-1)
