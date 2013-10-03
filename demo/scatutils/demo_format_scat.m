%% Demo of *format_scat*

%% Usage
% [out,meta] = *format_scat*(S,fmt) (see
% <matlab:doc('format_scat') format_scat>).
%
%% Description
% In this demo, we show one format_scat can be used to gather all
% scattering coefficients into one single array, and visualize this array
% using imagesc.
% NB : so as to improve contrast, the colormap only ranges from 0 to 2,
% setting all higher values in white.

N = 65536;
load handel;
y = y(1:N);
T = 4096;
filt_opt = default_filter_options('audio', T);
scat_opt.M = 2;
[Wop, filters] = wavelet_factory_1d(N, filt_opt, scat_opt);
S = scat(y, Wop);
fmt = 'table'; % default format
X = format_scat(S,fmt);

figure;
coefft = (1:size(X,1));
time = (1:size(X,2)) * T/Fs;
imagesc(time,coefft,X);
colormap bone;
caxis([0 2]); % color thresholding improves contrast
colorbar;
xlabel('Time (seconds)');
ylabel('Coefficients');