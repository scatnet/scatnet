%% Demo of *display_filter_bank_2d*
% The display filter functions returns an image corresponding to the filter
% display in spatial domain.
%
%% Usage
%  big_img=*display_filter_bank_2d*(filters, n, renorm)
%
%% Examples
% The renormalization corresponds to a renormalization by the maximum
% amplitude of the wavelet
%
% This displays the whole filter bank used in Fourier multiresolution. Here
% n designs the size of the filter one wants to display.
x = mandrill;
[Wop, filters] = wavelet_factory_2d(size(x));
n = 30;
renorm = 1;
display_filter_bank_2d(filters, renorm, n);


% This displays the whole filter bank used in Fourier multiresolution.
% Here, the parameter n is not used. This displays the "h" and "g" filters for
% the cascading algorithm.
x = mandrill;
[Wop, filters] = wavelet_factory_2d_pyramid();
renorm = 1;
display_filter_bank_2d(filters, renorm, n);




