%%  Introduction to *wavelet_2d*
% *wavelet_2d* is a function able to compute the wavelet transform of a
% signal. Given $$ J \in \bf{N} $$, the wavelet transform of a signal 
% $$ x \in \bf{R}^N $$
% is given by
%
% $$ Wf(x) =\{x\ast \phi_J, x\ast\psi_{\lambda}\}_{\lambda \in \mathcal{P}} $$
% where in our case $\mathcal{P}=\{\lambda=2^{-j}r,r \in G_+, j<J\}$ is the
% index of a set of filters.
%
%% Usage
% [x_phi, x_psi] = *wavelet_2d*(x, filters, options) (see
% <matlab:doc('wavelet_2d') wavelet_2d>).
%
%% Description
% It is possible to create some wavelet filters with wavelet_factory_2d for 
% instance. The filter size have to be adapted to the size of the input
% signal $x$.

x = mandrill;
filters = morlet_filter_bank_2d(size(x));
[x_phi,x_psi]=wavelet_2d(mandrill,filters);
figure;

colormap gray;

subplot(1,2,1)
imagesc(real(x_psi{1}))
axis square
axis off
title({'Real part of the first';'wavelet transform coefficient'});
subplot(1,2,2)
imagesc(imag(x_psi{1}))
axis square
axis off
title({'Imaginary part of the first';'wavelet transform coefficient'});

%% Options
% Several options are available with wavelet_2d that allow the user to
% change the output or the way to compute it.
% 
% * options.x_resolution = 0 changes the resolution on which
% the wavelet transform is computed by a factor 2.
% * options.precision = 'single' allows to compute either with 'double' or
% 'single'.
% * options.oversampling = 1 oversamples the signal by a factor 2.
% * options.psi_mask = [1 ... 1] is of a size the number of filters and
% allows to compute the signal only when the corresponding wavelet has a
% '1' in its respective psi_mask.
