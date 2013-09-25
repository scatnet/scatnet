% a script to reproduce figure 4 of paper 
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

% display it
colormap gray;
display_filter_bank_2d(filters);