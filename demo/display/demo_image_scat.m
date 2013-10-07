%%  Introduction to *image_scat*
% *image_scat* is a function to visualize scattering coefficients. It will
% display the output of every path of the scattering.
%
%% Usage
% output_image = *image_scat*(S); where *S* is the output of *scat*.
%
%% Example
% The following code will produce 3 images.
x = lena;
[Wop,filters] = wavelet_factory_2d(size(x));
[S,U] = scat(x,Wop);
image_scat(S);

% They correspond to the resulting scattering coefficients of each paths
% for each layer and each rotation. The legend indicates the path and the resolution.
% These filters are normalized but the normalization can be removed by
% modifying the option of image_scat. The legend too can be removed using
% too an option.
%
% The part of the image where the legend is, has some transparent blue to 
% help reading the coefficients, this is not a bug but it is here to be 
% convenient for the readers.
%
% On the Figure 2 for instance, there is 2 different j. The first one
% corresponds to the scale of the used wavelets whereas the second one
% corresponds to the scale of the low-pass filter which is thus constant.