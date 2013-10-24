%% simple example of use for renorm_sibling_2d
%% compute scattering
clear;
x = mandrill;
%%
Wop = wavelet_factory_2d_pyramid();
Sx = scat(x, Wop);
%% renormalize with L1 norm
op = @(x)(sum(x,3));
Sxrenorm = renorm_sibling_2d(Sx, op);


%% more sophisticated example of use for renorm_sibling_2d
%% compute scattering
clear;
x = mandrill;
Wop = wavelet_factory_2d_pyramid();
Sx = scat(x, Wop);

%% smooth a bit + L1 accross sibling
op = renorm_factory_L1_smoothing(1);
[Sx_renorm, siblings]  = renorm_sibling_2d(Sx, op);

image_scat(Sx,0,0);

%%
image_scat(Sx_renorm,0,0);

%%
sx = format_scat(Sx);
sxs = sum(sum(sx,2),3);

Rsx = format_scat(Sx_renorm);
Rsxs = sum(sum(Rsx,2),3);
plot([sxs,Rsxs])


%% test with non-default parameters
clear; close all;

%% compute scattering
x = mandrill;
options.Q = 1;
Wop = wavelet_factory_2d_pyramid(options, options);
Sx = scat(x, Wop);
%% 
op = renorm_factory_L1_smoothing(3);
[Sx_renorm, siblings]  = renorm_sibling_2d(Sx, op);

image_scat(Sx,0,0);
image_scat(Sx_renorm,0,0);
