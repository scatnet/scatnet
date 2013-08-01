clear;
x = uiuc_sample;
options.J = 5;
options.M = 2;


Wop = wavelet_factory_3d_spatial(options, options, options);

Sx = scat(x, Wop);
%%
Sx_renorm = renorm_scat_spatial(Sx);
ssx = mean(mean(format_scat(Sx),2),3);
ssx_rn = mean(mean(format_scat(Sx_renorm),2),3);
plot([ssx(2:end),ssx_rn(2:end)])