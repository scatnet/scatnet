N = 65536;
load handel;
y = y(1:N);

filt_opt = default_filter_options('audio', 4096);

scat_opt.M = 2;

Wop = wavelet_factory_1d(N, filt_opt, scat_opt);

S = scat(y, Wop);

j1 = 23;
scattergram(S{2},[],S{3},j1);

S = renorm_scat(S);
S = log_scat(S);

scattergram(S{2},[],S{3},j1);
