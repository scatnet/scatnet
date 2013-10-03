%% Demo of *plot_littlewood_paley_1d*

%% Usage
% littlewood = *plot_littlewood_paley_1d*(filters) (see
% <matlab:doc('plot_littlewood_paley_1d') plot_littlewood_paley_1d>).
%
%% Description
% *plot_littlewood_paley* computes, at every frequency, the 
% Littlewood-Paley sum of a filter bank, i.e. the total power spectral
% density
% \sum_{j, \theta} |\hat{\psi_j} (\omega)|^2 + |\hat{\phi_J}(\omega)|^2
% If this sum is between $(1-epsilon)$ and $1$ for small $epsilon,
% the associated wavelet transform is proved to be contractive and
% almost unitary.

% In this demo, we display the Littlewood-Paley sum of a dyadic Morlet
% wavelet filter bank, with a very low averaging size of 8 samples. The
% Littlewood-Paley sum is shown in red, while the lowpass filter phi and
% the bandpass filters psi are respectively shown in green and blue.

figure;
T = 2^3;
interpolation = 2^10;
filt_opt.Q = 1;
filt_opt.J = T_to_J(T,filt_opt);
dyadic_filters = morlet_filter_bank_1d(T*interpolation,filt_opt);

plot_littlewood_paley_1d(dyadic_filters);
title('Q = 1 ; T = 8 samples (interpolated)');

% A more realistic example is constructed with an averaging size of 4096
% samples and a quality factor of 8. These values are typical in audio
% signal processing. The lowpass filter has such a narrow bandwidth that it
% is almost not visible in this second plot.

figure;
T = 2^12;
filt_opt.Q = 8;
filt_opt.J = T_to_J(T,filt_opt);
audio_filters = morlet_filter_bank_1d(T,filt_opt);

plot_littlewood_paley_1d(audio_filters);
title('Q = 8 ; T = 4096 samples');