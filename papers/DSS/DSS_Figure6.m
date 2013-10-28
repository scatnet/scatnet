% Generate Figure 6 of the "Deep Scattering Spectrum" paper.

% Load the signal.
x_file = load('Chord_display.mat');
x = x_file.X;

% Prepare the filters and scattering operators.
filt_opt.filter_type = {'gabor_1d','morlet_1d'};
filt_opt.B = [4 4];
filt_opt.Q = 4*filt_opt.B; 
filt_opt.J = T_to_J([256 8192],filt_opt);

scat_opt.oversampling = 8;
scat_opt.M = 2;

Wop = wavelet_factory_1d(length(x), filt_opt, scat_opt);

% Compute scattering coefficients.
[S, U] = scat(x, Wop);

% Renormalize coefficients.
epsilon = 1e-2;
S = renorm_scat(S, epsilon);
S = renorm_1st_phi(S, U, Wop, epsilon);

% Compute the logarithm.
S = log_scat(S,1e-3);
U = log_scat(U,1e-3);

% Display scalogram U{2}, first-order coefficients S{2} and second-order
% coefficients S{3} for j1 = 58.
scattergram(U{2}, [], S{2}, [], S{3}, 58);

