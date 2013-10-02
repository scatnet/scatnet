
%Reproduce the figure 6 of the paper "Deep Scattering Spectrum" , J. Anden
%and S. Mallat to be published in Transactions of Signal Processing.

%load the signal
v=load('Chord_display.mat');
v=v.X;

%Prepare the filters appropriate for audio processing
fparam.filter_type = {'gabor_1d','morlet_1d'};
fparam.B = [8 4];
fparam.Q = 4*fparam.B;

T = [1024 65536];

fparam.J = T_to_J(T,fparam);
%fparam.J(2) = T_to_J(65536,fparam.Q(2));

options.oversampling = 5;
options.M = 2;

Wop = wavelet_factory_1d(length(v), fparam, options);

%[Compute the scattering vector with options.oversampling set to 100
[S, U]=scat(v, Wop);

S = renorm_scat(S,1e-2);

S = log_scat(S,1e-6);
U = log_scat(U,1e-6);

%compute the scalograms for the orders 1 and 2(layerNb=1) and for j1=120;
scattergram(U{2},[],S{2},[],S{3},120);
