x = uiuc_sample;


opt.J = 6;
w = wavelet_factory_2d_spatial(opt, opt);
sx = scat(x, w);


%%

%%
sx_rn = renorm_scat_spatial(sx);

tmp = format_scat(sx_rn);
sx_rn_sum = squeeze(sum(sum(tmp,2),3));


tmp = format_scat(sx);
sx_sum = squeeze(sum(sum(tmp,2),3));
plot([sx_sum,sx_rn_sum]);
legend('vanilla', 'renorm');

