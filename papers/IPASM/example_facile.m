%
%
%this script produces the figures of the paper scattering_fractal_analysis
%september 2013
%Joan Bruna
%
%


close all;
%clear all;
%startup;

clear filt_opt;
clear scat_opt;
%set the maximum analysis scale
filt_opt.J = 14;
filt_opt.filter_format='fourier';
%size of realizations
N=2^(4+filt_opt.J);

%choose the wavelet
filt_opt.filter_type='selesnick_1d';
%filt_opt.filter_type='morlet_1d';
scat_opt.M=2;

scat_opt.path_margin= Inf;
[Wop, filters]=wavelet_factory_1d(N,filt_opt,scat_opt);

R=4;
options.Wop=Wop;
options.J=filt_opt.J;

poisson=@(alpha) (cumsum(double(rand(N,1) < N^(-alpha))));
dpoisson=@(alpha) ((double(rand(N,1) < N^(-alpha))));

[S{1},T{1},Tu{1},ex{1}] = scat_renorm_1d_scatnet(dpoisson, 0.6, options, R);

figure
plot_full_transfer(log2(T{1}));

oldopts.J=14;
oldopts.filters=selesnick_bis([N 1], oldopts);
oldopts.fullscatt=1;
oldopts.oversampling=oldopts.J;
[S{2},T{2},Tu{2},ex{2}] = scatt_renorm_estimation(dpoisson, 0.6, oldopts, R);

figure
plot_full_transfer(log2(T{2}));

