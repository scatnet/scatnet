% Generate Figure 7 of the "Deep Scattering Spectrum" paper.

% Load the signal.
x = wavread('mod_signal.wav');

% Prepare the filters and scattering operators.
filt_opt.filter_type = {'gabor_1d','morlet_1d'};
filt_opt.B = [8 4];
filt_opt.Q = 8*filt_opt.B;
filt_opt.J = T_to_J([256 4096],filt_opt);

scat_opt.oversampling = 3;
scat_opt.M = 2;

scat_opt.path_margin = 1;

Wop = wavelet_factory_1d(length(x), filt_opt, scat_opt);

% Compute scattering coefficients.
[S, U] = scat(x, Wop);

% Renormalize coefficients.
epsilon = 1e-3;
S = renorm_scat(S, epsilon);
S = renorm_1st_phi(S, U, Wop, epsilon);

S = resample_scat(S, 8);
U = resample_scat(U, 8);

% Compute the logarithm.
S = log_scat(S,1e-3);
U = log_scat(U,1e-3);

% Display scalogram U{2}, first-order coefficients S{2} and second-order
% coefficients S{3} for j1 = 110.
figure(7);
colormap(jet);
clf;
set(gcf,'Units','pixels','Position',[200 200 560 420]);
scattergram(U{2}, [], S{2}, [], S{3}, 110);
subplot(3,1,1);
set(gca,'XTick',[],'YTick',[]);
subplot(3,1,2);
set(gca,'XTick',[],'YTick',[]);
subplot(3,1,3);
set(gca,'XTick',[],'YTick',[]);
ylim([150.5 299.5]);
colormap(jet);

