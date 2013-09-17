clear;

x = lena;
Wop = wavelet_factory_2d_spatial();
Sx = scat(x, Wop);

%% smooth a bit + L1 accross sibling
options.sigma_phi = 1;
options.P = 4;
filters = morlet_filter_bank_2d_spatial(options);
h = filters.h.filter;
smooth = @(x)(convsub2d_spatial(x, h, 0));
op = @(x)(smooth(sum(x,3)) + 1E-20);
%op = @(x)(sum(x,3));

[Sx_renorm, siblings]  = renorm_sibling_2d(Sx, op);

image_scat(Sx,0,0);
image_scat(Sx_renorm,0,0);

%%
sx = format_scat(Sx);
sxs = sum(sum(sx,2),3);


%%
Rsx = format_scat(Sx_renorm);
Rsxs = sum(sum(Rsx,2),3);
plot([sxs,Rsxs])


