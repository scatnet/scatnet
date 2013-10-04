%%  Introduction to *wavelet_layer_2d*
% *wavelet_layer_2d* is computing the wavelet transform coefficient from 
% the coefficient of the previous layer. It should be applied iteratively
% to an input signal.
%
%% Usage
% [A, V] = *wavelet_layer_2d*(U, filters, options), documentation is given in
% <matlab:doc('wavelet_layer_2d') wavelet_layer_2d>
%
%% Description
% It is possible to create some wavelet filters with wavelet_factory_2d for 
% instance. The filters size have to be adapted to the size of the input
% signal $x$. 
clear; close all; 

x = lena;

% Create $ U[\empty]x $
U{1}.signal{1} = x;
U{1}.meta.j = zeros(0,1);
U{1}.meta.q = zeros(0,1);
U{1}.meta.resolution=0;
filters = morlet_filter_bank_2d(size(x));

% A corresponds to the output scattering coefficients, and V to the wavelet
% coefficients.
[A, V] = wavelet_layer_2d(U{1}, filters);

colormap gray
subplot(121)
imagesc(real(V.signal{1}))
axis off
title('Real part of the first wavelet transform coefficient');
subplot(122)
imagesc(imag(V.signal{1}))
axis off
title('Imaginary part of the first wavelet transform coefficient');


%% Options
% The options are the same as in *wavelet_2d*.
