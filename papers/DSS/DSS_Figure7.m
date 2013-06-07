%Reproduce the figure 7 of the paper "Deep Scattering Spectrum" , J. Anden
%and S. Mallat to be published in Transactions of Signal Processing.

tic
%load the signal
v=load('mod_display.mat');

v=v.X;
size(v);

%Prepare the filters appropriate for audio processing
fparam.filter_type = {'gabor_1d','morlet_1d'};
 fparam.B = [8 4];
 fparam.Q = 8*fparam.B;

 
fparam.J(1) = T_to_J(1024*2,fparam.Q(1));
fparam.J(2) = T_to_J(1024*32,fparam.Q(2));
options = struct();
options.oversampling=2;
Wop = wavelet_factory_1d(length(v), fparam,options, 2);

%[Compute the scattering vector with options.oversampling set to 100
[S, U]=scat(v, Wop);

S = renorm_scat(S,1e-2);

S = log_scat(S,1e-4);
U = log_scat(U,1e-4);

%compute the scalograms for the orders 1 and 2(layerNb=1) and for j1=120
scattergram(U{2},[],S{2},[],S{3},110);

