%%  Introduction to *image_scat*
% *image_scat* is a function to visualize scattering coefficients. It will
% display the output of every path of the scattering.
%
%% Usage
% output_image = *image_scat*(S); where *S* is the output of *scat*.
%
%% Example
% The following code will produce 3 images.
x = mandrill;
[Wop,filters] = wavelet_factory_2d(size(x));
[S,U] = scat(x,Wop);
image_scat(S);

% They correspond to the resulting scattering coefficients of each paths
% for each layer and each rotation. The legend indicates the path and the resolution.
% These filters are normalized but the normalization can be removed by
% modifying the option of image_scat. The caption can also be removed with
% a specific option.
%
% To improve legibility, the image background behind the caption is
% artificially enlightened.
%
% On the Figure 2 for instance, there is 2 different j. The first one
% corresponds to the scale of the used wavelets whereas the second one
% corresponds to the scale of the low-pass filter which is thus constant.
