% a script that demonstrate that the wavelet transform is perfectly unitary
% when a filter bank that perfectly tiles the frequency plane is used

x = lena;
filt_opt.min_margin = 0;
filters = shannon_filter_bank_2d(size(x), filt_opt);
wav_opt.oversampling = 1;
[x_phi, x_psi] = wavelet_2d(x, filters, wav_opt);
norm_x = sum(x(:).^2);
norm_Wx = sum(x_phi(:).^2) + sum(cellfun(@(x)(sum(abs(x(:)).^2)), x_psi));