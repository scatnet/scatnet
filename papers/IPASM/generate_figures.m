%
%
%this script produces the figures of the paper scattering_fractal_analysis
%september 2013
%Joan Bruna
%
%


close all;
clear all;

%set the maximum analysis scale
filt_opt.J = 14;
filt_opt.filter_format='fourier';
%size of realizations
N=2^(4+filt_opt.J);

%choose the wavelet
filt_opt.filter_type='selesnick_1d';
%filt_opt.filter_type='morlet_1d';
scat_opt.M=2;

[Wop, filters]=wavelet_factory_1d(N,filt_opt,scat_opt);

scat_opt.path_margin= Inf;
[Wopinf]=wavelet_factory_1d(N,filt_opt,scat_opt);

R=16;
snmin=-4;
snmax=1;
options.Wop=Wop;
options.J=filt_opt.J;

%%construct different stochastic processes

%%Fractional Brownian Motions and Fractional Gaussian Noise
FBM=@(H) (cumsum(fGnsimu(N,H)'));
FGN=@(H) ((fGnsimu(N,H)'));

%dissip-FBM
FGNdissip=@(H) (abs(fGnsimu(N,H)').^2);

%%Poisson processes
poisson=@(alpha) (cumsum(double(rand(N,1) < N^(-alpha))));
poissons=@(alpha) ((double(rand(N,1) < N^(-alpha))));

%Lévy alpha-stable
levy=@(alpha) (cumsum(stblrnd(alpha,0,1,0,[N 1])));

%Multifractal Random Measures
dMRM=@(la) (MRWsimu(N,0,la(1),2^la(2))');
MRM=@(la) (cumsum(MRWsimu(N,0,la(1),2^la(2))'));

%%Multifractal Random Walks
dMRW=@(la) (MRWsimu(N,1,la(1),2^la(2))');
MRW=@(la) (cumsum(MRWsimu(N,1,la(1),2^la(2))'));


%section 2 figures%%
%TODO: how to set the non-progressive paths offset?

r=1;
%figure 1: Poisson Process
%this figure creates a poisson process and its associated jump process,
%and computes its scattering coefficients, which validate the results
%of theorem 2.2

optionsinf = options;
optionsinf.Wop = Wopinf;
[S{r},T{r},Tu{r},ex{r}] = scat_renorm_1d_scatnet(poisson, 0.6, optionsinf, R);r=r+1;
[S{r},T{r},Tu{r},ex{r}] = scat_renorm_1d_scatnet(poissons, 0.6, optionsinf, R);r=r+1;

figure;
plot(ex{1}(1:2^17));
figure; 
plot(log2(S{1}));hold on;plot(log2(S{2}),'r');legend('X','dX');hold off;
figure;
plot_full_transfer(log2(T{1}));
figure;
plot_stat_transfer(log2(T{1}),11,11,1);



%section 3

%figure 2: Brownian Motion.
%Here we validate the self-similarity invariance property
%of renormalized second order scattering coefficients, by 
%testing it on Fractional Brownian Motions

[S{r},T{r},Tu{r},ex{r}] = scat_renorm_1d_scatnet(FBM, 0.5, optionsinf, R);r=r+1;
figure;
plot(ex{r-1}(1:2^17));
figure;
plot(log2(S{r-1}));
figure;
plot_full_transfer(log2(T{r-1}));


%figure 3: Fractional Brownian Motions
options.fullscatt=0;
H=[0.2 0.4 0.6 0.8];
for h=1:length(H)
[S{r},T{r},Tu{r},ex{r}] = scat_renorm_1d_scatnet(FBM, H(h), options, R);r=r+1;
end
figure;
plot(ex{r-4}(1:2^17));
figure;
plot(ex{r-1}(1:2^17));
figure;
plot(log2(S{r-4}));hold on;
plot(log2(S{r-3}),'r');
plot(log2(S{r-2}),'g');
plot(log2(S{r-1}),'m');
legend('0.2', '0.4', '0.6', '0.8'); hold off;
figure;
plot(log2(Tu{r-4}));hold on;
plot(log2(Tu{r-3}),'r');
plot(log2(Tu{r-2}),'g');
plot(log2(Tu{r-1}),'m');
legend('0.2', '0.4', '0.6', '0.8'); hold off;
%axis([0 length(Tu{r-4}) snmin snmax])


%figure 4:Levy processes
%%alpha-stable levy processes are another family of self-similar processes
%%which are more intermittent than FBMs. This is expressed by a slower
%%decay on its second order scattering coefficients.
H=[1.1 1.3 1.5];
for h=1:length(H)
[S{r},T{r},Tu{r},ex{r}] = scat_renorm_1d_scatnet(levy, H(h), options, R);r=r+1;
end
figure;
plot(ex{r-3}(1:2^17));
figure;
plot(ex{r-1}(1:2^17));
figure;
plot(log2(S{r-3}));hold on;
plot(log2(S{r-2}),'r');
plot(log2(S{r-1}),'g');
legend('1.1', '1.3', '1.5'); hold off;
figure;
plot(log2(Tu{r-3}));hold on;
plot(log2(Tu{r-2}),'r');
plot(log2(Tu{r-1}),'g');
legend('1.1', '1.3', '1.5'); hold off;
%axis([0 length(Tu{r-3}) snmin snmax])


%section 4

%figure 5:Multiplicative Cascades.
%% Here we validate that the self-similarity invariance property also 
%%holds for processes with stochastic self-similarity, such as Multiplicative Cascades.
intscale=13;
lambda=0.04;
[S{r},T{r},Tu{r},ex{r}] = scat_renorm_1d_scatnet(MRM, [lambda intscale], options, R);r=r+1;
figure;
plot_stat_transfer(log2(T{r-1}),options.J,options.J,1);
figure;
plot_stat_transfer(log2(T{r-1}),intscale-1,intscale-1,1);


%figure 6:MRMs
%% Scattering coefficients of Multifractal Random Measures and Multifractal Random Walks. 
%% These are very intermittent processes, and its second order scattering have no decay
%% as long as the scales don't reach the integral scale of the process.
H=[0.04 0.07 0.1];
for h=1:length(H)
[S{r},T{r},Tu{r},ex{r}] = scat_renorm_1d_scatnet(MRM, [H(h) intscale], options, R);r=r+1;
end
figure;
plot(ex{r-3}(1:2^17));
figure;
plot(ex{r-1}(1:2^17));
figure;
plot(log2(S{r-3}));hold on;
plot(log2(S{r-2}),'r');
plot(log2(S{r-1}),'g');
legend('0.04', '0.07', '0.1'); hold off;
figure;
plot(log2(Tu{r-3}));hold on;
plot(log2(Tu{r-2}),'r');
plot(log2(Tu{r-1}),'g');
legend('0.04', '0.07', '0.1'); hold off;
%axis([0 length(Tu{r-3}) snmin snmax])


%figure 7:MRWs
for h=1:length(H)
[S{r},T{r},Tu{r},ex{r}] = scat_renorm_1d_scatnet(MRW, [H(h) intscale], options, R);r=r+1;
end
figure;
plot(ex{r-3}(1:2^17));
figure;
plot(ex{r-1}(1:2^17));
figure;
plot(log2(S{r-3}));hold on;
plot(log2(S{r-2}),'r');
plot(log2(S{r-1}),'g');
legend('0.04', '0.07', '0.1'); hold off;
figure;
plot(log2(Tu{r-3}));hold on;
plot(log2(Tu{r-2}),'r');
plot(log2(Tu{r-1}),'g');
legend('0.04', '0.07', '0.1'); hold off;
%axis([0 length(Tu{r-3}) snmin snmax])




