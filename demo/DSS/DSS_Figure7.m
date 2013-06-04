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
options.antialiasing=2;
cascade = wavelet_factory_1d(length(v), fparam,options, 2);

%[Compute the scattering vector with options.antialiasing set to 100
[Sv, U]=scat(v,cascade);



%compute the scalograms for the orders 1 and 2(layerNb=1) and for j1=120
scattergram(U,Sv,2,110,1e-1,1e-2,1e-2);


