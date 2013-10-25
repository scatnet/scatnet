%%  Introduction to *wavelet_factory_2d*
% *wavelet_factory_2d* is computing operators(except the modulus) and 
% filters required to compute the next layer of a scattering network.
%
%% Usage
% [Wop, filters] = wavelet_factory_2d(size_in, filt_opt, scat_opt), documentation is given in
% <matlab:doc('wavelet_factory_2d') wavelet_factory_2d>
%
%% Description
% Given a size image, some filters options and scattering options, this
% function comput the linear operators necessar to compute the next
% coefficients of scattering.

x = mandrill;

% Create $ U[\empty]x $
[Wop, filters] = wavelet_factory_2d(size(x));

% Then one can apply Wop as in *scat*. Please reference to its
% documentation.


%% Options
% filt_opt has the same fields as in *morlet_filter_bank_2d*.
%
% scat_opt has the same fields as in *wavelet_layer_2d*.
%
% See their documentation for more details.
