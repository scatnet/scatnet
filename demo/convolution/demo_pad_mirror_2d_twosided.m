% DEMO_PAD_MIRROR_2D_TWOSIDED Demonstrate usage of PAD_MIRROR_2D_TWOSIDED
% 
% See also
%   PAD_MIRROR_2D_TWOSIDED

clear; close all;

x = uiuc_sample;
margins = [10, 100];
x_paded = pad_mirror_2d_twosided(x, margins);

subplot(121);
imagesc(x);
title('original image');
subplot(122);
imagesc(x_paded);
title('image paded (10 vertical 100 horizontal)');

colormap gray;
