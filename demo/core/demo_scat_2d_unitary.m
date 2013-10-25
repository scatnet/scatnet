%%  Introduction to norm-preserving wavelet and scattering 
% This script demonstrates that wavelet transform and scattering operators
% may perfectly preserves if the filter bank has a constant littlewood
% paley sum

%% clear the workspace and load an image
clear; close all;
x = mandrill;

%% build the wavelet transform operator with shannon filters
size_in = size(x);

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
%% 
display_filter_bank_2d(filters);

%% compute scattering
[Sx, Ux] = scat(x, Wop);

%% display
image_scat(Ux,0,0)

%% compute the scattering energy for different combination of layer

e1 = scat_energy(Ux{1});
e2 = scat_energy(Sx{1}) + scat_energy(Ux{2});
e3 = scat_energy(Sx{1}) + scat_energy(Sx{2});
e4 = scat_energy(Sx{1}) + scat_energy(Sx{2}) + scat_energy(Ux{3});
e5 = scat_energy(Sx);

fprintf('enegergy for the original image x : %.5f \n', e1);
fprintf('sum of enegergy for S0 and U1     : %.5f \n', e2);
fprintf('sum of enegergy for S0 and S1     : %.5f \n', e3);
fprintf('sum of enegergy for S0, S1 and U2 : %.5f \n', e4);
fprintf('sum of enegergy for S0, S1 and S2 : %.5f \n', e5);

%% ratio of energy 
fprintf('ratio for S0 and U1     : %.5f \n', e2/e1);
fprintf('ratio for S0 and S1     : %.5f \n', e3/e1);
fprintf('ratio for S0, S1 and U2 : %.5f \n', e4/e1);
fprintf('ratio for S0, S1 and S2 : %.5f \n', e5/e1);
