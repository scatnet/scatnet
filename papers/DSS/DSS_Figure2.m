% Generate Figure 2 of the "Deep Scattering Spectrum" paper.

% Load signal (music).
x = wavread('kodaly.wav');

% Prepare filters.
filt_opt.B = 8;
filt_opt.Q = 4*filt_opt.B;
filt_opt.J = T_to_J(4096, filt_opt);
filt_opt.boundary = 'per';

filters = filter_bank(length(x), filt_opt);

% Extract Fourier transform of filters and assemble into a table.
psi_f = cellfun(@realize_filter, filters{1}.psi.filter, 'UniformOutput', 0);
psi_f = [psi_f{:}];

% Calculate the Fourier transform of the squared lowpass filter.
phi2 = fft(abs(ifft(realize_filter(filters{1}.phi.filter))).^2);
phi2 = phi2/phi2(1);

% Calculate the scalogram - amplitude of filter bank responses - and square.
xt1 = abs(ifft(bsxfun(@times, fft(x), psi_f))).^2;

% Smooth the squared scalogram using the square lowpass filter.
xt2 = ifft(bsxfun(@times, fft(xt1), phi2));

% We only need to see the highest seven octaves.
xt1 = xt1(:,1:7*filt_opt.Q);
xt2 = xt2(:,1:7*filt_opt.Q);

% Compute the logarithm.
xt1 = log(xt1+1e-6);
xt2 = log(xt2+1e-6);

% Display the representations.
figure(2);
subplot(121);
imagesc(xt1.');
set(gca,'XTick',[]);
set(gca,'YTick',[]);
subplot(122);
imagesc(xt2.');
set(gca,'XTick',[]);
set(gca,'YTick',[]);
