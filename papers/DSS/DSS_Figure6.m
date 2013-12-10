% Generate Figure 6 of the "Deep Scattering Spectrum" paper.

% Load the signal.
x = wavread('chord_signal.wav');

% Prepare the filters and scattering operators.
filt_opt.filter_type = {'gabor_1d','morlet_1d'};
filt_opt.B = [4 4];
filt_opt.Q = 4*filt_opt.B; 
filt_opt.J = T_to_J([256 32768],filt_opt);

scat_opt.oversampling = 3;
scat_opt.M = 2;

Wop = wavelet_factory_1d(length(x), filt_opt, scat_opt);

% Compute scattering coefficients.
[S, U] = scat(x, Wop);

% Renormalize coefficients.
epsilon = 1e-3;
S = renorm_scat(S, epsilon);
S = renorm_1st(S, x, Wop{2}, epsilon);

S = resample_scat(S, 8, false);
U = resample_scat(U, 6, false);

% Compute the logarithm.
S = log_scat(S, 1e-3);
U = log_scat(U, 1e-3);

% Display scalogram U{2}, first-order coefficients S{2} and second-order
% coefficients S{3} for j1 = 58.
figure(6);
clf;
set(gcf,'Units','pixels','Position',[200 200 560 420]);
scattergram(U{2}, [], S{2}, [], S{3}, 58);
subplot(3,1,1);
set(gca,'XTick',[],'YTick',[]);
subplot(3,1,2);
set(gca,'XTick',[],'YTick',[]);
subplot(3,1,3);
set(gca,'XTick',[],'YTick',[]);
colormap(jet);

