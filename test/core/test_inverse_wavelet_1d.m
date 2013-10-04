filt_opt.J = 3;
filters1d = morlet_filter_bank_1d(32, filt_opt);
dual_filters1d = dual_filter_bank(filters1d);

rs = RandStream.create('mt19937ar','Seed',1234);
x = rs.randn(32,1);

wavelet_opt.oversampling = 2;
[x_phi,x_psi,meta_phi,meta_psi] = wavelet_1d(x(1:32),filters1d,wavelet_opt);
x1 = inverse_wavelet_1d(32, x_phi, x_psi, meta_phi, meta_psi, dual_filters1d);
assert(norm(x-x1)/norm(x)<0.02)

wavelet_opt.oversampling = 100;
[x_phi,x_psi,meta_phi,meta_psi] = wavelet_1d(x(1:32),filters1d,wavelet_opt);
x1 = inverse_wavelet_1d(32, x_phi, x_psi, meta_phi, meta_psi, dual_filters1d);
assert(norm(x-x1)/norm(x)<1e-14)