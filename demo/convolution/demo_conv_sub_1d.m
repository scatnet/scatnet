%% Demo of conv_sub_1d

%% Usage
% y_ds = CONV_SUB_1D(xf, filter, ds) (see <matlab:doc('conv_sub_1d') ...
% conv_sub_1d>)
%
%% Description
% In this demo, we show how conv_sub_1d carries out a product in the
% frequency domain, equivalent to a convolution in time, along with a
% downsampling of the output signal.

% First, import an input signal and compute its Fourier transform
N = 65536;
load handel;
x = y(1:N);
xf = fft(x);

% Then, build a constant-Q filterbank
T = 4096; % averaging size
filt_opt.Q = 8; % quality factor
filt_opt.J = T_to_J(T,filt_opt); % number of scales
filt_opt.filter_format = 'fourier_truncated'; % default format
filters = filter_bank(N,filt_opt);
% an arbitrary filter within the filter bank

% Perform CONV_SUB_1D
ds = 0; % log2 of downsampling factor
filter = filters{1}.psi.filter{10};
y = conv_sub_1d(xf,filter,ds);

% Plot the filtered signal
plot(abs(y));