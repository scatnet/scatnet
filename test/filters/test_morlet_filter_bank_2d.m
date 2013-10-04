% compute filters
size_in = [128, 128];
filt_opt.L = 6;
filt_opt.Q = 1;
filt_opt.J = 3;
filters = morlet_filter_bank_2d(size_in, filt_opt);

assert(filters.meta.Q==filt_opt.Q);
assert(filters.meta.J==filt_opt.J);
assert(filters.meta.L==filt_opt.L);
assert(abs(filters.meta.sigma_phi-0.80)<1e-2);
assert(abs(filters.meta.sigma_psi-0.80)<1e-2);
assert(abs(filters.meta.xi_psi-2.3562)<1e-2);
assert(abs(filters.meta.slant_psi-0.6667)<1e-2);
assert(all(filters.meta.size_in==[128 128]));
assert(all(filters.meta.size_filter==[136 136]));
assert(all(filters.meta.margins==[8 8]));

assert(length(filters.psi.filter)==18);

phi = realize_filter(filters.phi.filter);
assert(abs(phi(1,1)-1)<1e-14);
assert(abs(norm(phi)-11.9890)<1e-2);

assert(filters.phi.meta.J==3);

psi = realize_filter(filters.psi.filter{1});
assert(abs(psi(1,1)-0)<1e-14);
assert(abs(norm(psi)-37.3459)<1e-2);

[j,theta] = meshgrid([0:filt_opt.J-1],[1:filt_opt.L]);
assert(all(filters.psi.meta.j==j(:)'));
assert(all(filters.psi.meta.theta==theta(:)'));

assert(strcmp(class(psi),'double'));

% display
figure(1);
display_filter_bank_2d(filters, 32, 1);
colormap gray;
figure(2);
display_littlewood_paley_2d(filters);