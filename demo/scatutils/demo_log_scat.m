%% Demo of *log_scat*

%% Usages
% [out,meta] = *log_scat*(S)
%
% [out,meta] = *log_scat*(S,epsilon) (see
% <matlab:doc('log_scat') log_scat>).
%
%% Description
% In this demo, we show how log_scat takes the logarithm of every component
% in a scattering transform, while preserving the network structure. This
% a posteriori transformation is particularly useful for visualisation and
% classification. We also show that the optional parameter epsilon acts as
% a thresholding operator in the colormap.

% First, let us compute the log-scattering coefficients S of an audio
% sample, with default epsilon = 2^(-20).

N = 65536;
load handel;
y = y(1:N);
T = 4096;
filt_opt = default_filter_options('audio', T);
scat_opt.M = 2;
[Wop, filters] = wavelet_factory_1d(N, filt_opt, scat_opt);
S = scat(y, Wop);

epsilon = 2^(-20); % default value
log_S = log_scat(S,epsilon);
X = format_scat(log_S); % gathers all scattering coefficients into a matrix

figure;
coefft = (1:size(X,1));
time = (1:size(X,2)) * T/Fs;
imagesc(time,coefft,X);
colormap bone;
colorbar;
xlabel('Time (seconds)');
ylabel('Coefficients');
title(sprintf('Log-scattering coefficients for epsilon=%1.2g',epsilon));


% The coefficients in S whose amplitude is small with respect to epsilon
% correspond to minimal values of approximately log(epsilon) in log_S.
% Henceforth, they are assigned the lowest brightness tone in the colormap.
% Since the colormap is automatically scaled between the lowest and highest
% value, raising epsilon by several order of magnitude shrinks the colormap
% and thus improves brightness contrast, at the cost of losing fine
% variations.

epsilon = 2^(-5); % high value
log_S = log_scat(S,epsilon);
X = format_scat(log_S);

figure;
coefft = (1:size(X,1));
time = (1:size(X,2)) * T/Fs;
imagesc(time,coefft,X);
colormap bone;
colorbar;
xlabel('Time (seconds)');
ylabel('Coefficients');
title(sprintf('Log-scattering coefficients for epsilon=%1.2g',epsilon));
