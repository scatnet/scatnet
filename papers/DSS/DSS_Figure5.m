% Generate Figure 5 of the "Deep Scattering Spectrum" paper.

% Load first signal (speech).
x1 = wavread('questions.wav');

% Prepare filters.
filt_opt.B = [8 1];
filt_opt.Q = 2*filt_opt.B;
filt_opt.J = T_to_J([1024 2048], filt_opt);

% Set inversion options. Just use defaults here.
inv_scat_opt = struct();

% Prepare first-order scattering transform.
scat_opt.M = 1;
[Wop, filters] = wavelet_factory_1d(length(x1), filt_opt, scat_opt);

% Calculate scattering and reconstruct.
S = scat(x1, Wop);
x1t1 = inverse_scat(S, filters, inv_scat_opt);

% Prepare second-order scattering transform.
scat_opt.M = 2;
[Wop, filters] = wavelet_factory_1d(length(x1), filt_opt, scat_opt);

% Calculate scattering and reconstruct.
S = scat(x1, Wop);
x1t2 = inverse_scat(S, filters, inv_scat_opt);

% Load second signal (music)
x2 = wavread('kodaly.wav');
x2 = x2(4097:4096+16384);

% Prepare filters.
filt_opt.J = T_to_J([1024 4096], filt_opt);

% Prepare first-order scattering transform.
scat_opt.M = 1;
[Wop, filters] = wavelet_factory_1d(length(x2), filt_opt, scat_opt);

% Calculate scattering and reconstruct.
S = scat(x2, Wop);
x2t1 = inverse_scat(S, filters, inv_scat_opt);

% Prepare second-order scattering transform.
scat_opt.M = 2;
[Wop, filters] = wavelet_factory_1d(length(x2), filt_opt, scat_opt);

% Calculate scattering and reconstruct.
S = scat(x2, Wop);
x2t2 = inverse_scat(S, filters, inv_scat_opt);

% Prepare display scalogram.
log_epsilon = 1e-4;
disp_filt_opt.B = 8;
disp_filt_opt.Q = 4*disp_filt_opt.B;
disp_filt_opt.J = T_to_J(1024, disp_filt_opt);
disp_scat_opt.M = 1;
disp_scat_opt.oversampling = 9;

dWop = wavelet_factory_1d(length(x1), disp_filt_opt, disp_scat_opt);

% Calculate scalograms for originals and reconstructions.
[temp,U1] = scat(x1, dWop);
[temp,U1t1] = scat(x1t1, dWop);
[temp,U1t2] = scat(x1t2, dWop);

[temp,U2] = scat(x2, dWop);
[temp,U2t1] = scat(x2t1, dWop);
[temp,U2t2] = scat(x2t2, dWop);

% Display scalograms.
figure(5);
clf;
set(gcf,'Units','inches','Position',[3 3 5.5 4.0]);
axes('Units','inches','Position',[0.25 2.25 1.50 1.50]);
scattergram(resample_scat(log_scat(U1{2}, log_epsilon), 5, false),[]);
set(gca,'XTick',[],'YTick',[]);
axes('Units','inches','Position',[2.00 2.25 1.50 1.50]);
scattergram(resample_scat(log_scat(U1t1{2}, log_epsilon), 5, false), []);
set(gca,'XTick',[],'YTick',[]);
axes('Units','inches','Position',[3.75 2.25 1.50 1.50]);
scattergram(resample_scat(log_scat(U1t2{2}, log_epsilon), 5, false), []);
set(gca,'XTick',[],'YTick',[]);
axes('Units','inches','Position',[0.25 0.25 1.50 1.50]);
scattergram(resample_scat(log_scat(U2{2}, log_epsilon), 5, false), []);
set(gca,'XTick',[],'YTick',[]);
axes('Units','inches','Position',[2.00 0.25 1.50 1.50]);
scattergram(resample_scat(log_scat(U2t1{2}, log_epsilon), 5, false), []);
set(gca,'XTick',[],'YTick',[]);
axes('Units','inches','Position',[3.75 0.25 1.50 1.50]);
scattergram(resample_scat(log_scat(U2t2{2}, log_epsilon), 5, false), []);
set(gca,'XTick',[],'YTick',[]);
colormap(jet);

