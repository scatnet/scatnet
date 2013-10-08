% a script that demonstrates unitary property of scattering when a 
% filter bank that perfectly tiles the frequency plane is used
clear; close all;
x = lena;
size_in = size(x);
%% build the wavelet transform operator with shannon filters
filt_opt = struct();
filt_opt.min_margin = [0,0];

% shannon filter bank as the perfect frequency tiling property
% i.e. it has a constant 1 littlewood paley sum
filt_opt.filter_type = 'shannon';


scat_opt = struct();
scat_opt.oversampling = 0;
[Wop, filters] = wavelet_factory_2d(size_in, filt_opt, scat_opt);

%% perfectly flat littlewood paley sum
imagesc(littlewood_paley(filters));

%% compute scattering
[Sx, Ux] = scat(x, Wop);

%% display
image_scat(Ux,0,0)

%%
e1 = scat_energy(Ux{1});

e2 = scat_energy(Sx{1}) + scat_energy(Ux{2});

% perfect energy conservation fo e2
e3 = scat_energy(Sx{1}) + scat_energy(Sx{2}) + scat_energy(Ux{3});

% e3 is slightly less than e1 and e2 because we only have computed
% path of increasing scale
e4 = scat_energy(Sx);


fprintf('enegergy of original image x     %.5f \n', e1);
fprintf('sum of enegergy of S0 and U1     %.5f \n', e2);
fprintf('sum of enegergy of S0, S1 and U2 %.5f \n', e3);
fprintf('sum of enegergy of S0, S1 and S2 %.5f \n', e4);
% the final smoothing almost lose no energy

%% ratio
fprintf('ratio x vs S0+U1      %.5f \n',e2/e1);
fprintf('ratio x vs S0+S1+U2   %.5f \n',e3/e1);
fprintf('ratio x vs S0+S1+S2   %.5f \n',e4/e1);