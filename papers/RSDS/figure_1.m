% a script to reproduce figure 1 of paper 
%
%   ``Rotation, Scaling and Deformation Invariant Scattering 
%   for Texture Discrimination"
%   Laurent Sifre, Stephane Mallat
%   Proc. IEEE CVPR 2013 Portland, Oregon
%

clear; close all;

% build a filter bank of oriented and dilated morlet wavelets
size_in = [512, 512];
options.margins = [0, 0];
filters = morlet_filter_bank_2d(size_in, options);

% build two grids of dirac
dirac_step = 64;
dirac_grid_1 = zeros(size_in);
dirac_grid_1(1:dirac_step:end, 1:dirac_step:end) = 1;
dirac_grid_2 = zeros(size_in);
dirac_grid_2(dirac_step/2+1:dirac_step:end, ...
    dirac_step/2+1:dirac_step:end) = 1;

% convolves the grid with morlet filters
dirac_grid_1_f = fft2(dirac_grid_1);
dirac_grid_2_f = fft2(dirac_grid_2);

psi_1 = filters.psi.filter{17};
psi_2 = filters.psi.filter{17+4};

texture_1 = conv_sub_2d(dirac_grid_1_f, psi_1, 0);
texture_1 = texture_1 + conv_sub_2d(dirac_grid_1_f, psi_2, 0);

texture_2 = conv_sub_2d(dirac_grid_1_f, psi_1, 0);
texture_2 = texture_2 + conv_sub_2d(dirac_grid_2_f, psi_2, 0);

% take real part
texture_1 = real(texture_1);
texture_2 = real(texture_2);

% display the two textures
subplot(121);
imagesc(texture_1);
subplot(122);
imagesc(texture_2);
colormap gray;