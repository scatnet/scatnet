x = uiuc_sample;
Wop = wavelet_factory_2d(size(x));
%% compute scattering 
[Sx, Ux] = scat(x, Wop);
%% 
image_scat(Sx);
%%
image_scat(Ux);

