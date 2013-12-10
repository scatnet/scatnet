% Generate Figure 1 of the "Deep Scattering Spectrum" paper.

% Load the signal.
x = wavread('dilation.wav');

% Prepare the spectrogram parameters.
window_size = 128;
hop_size = window_size/32;
fft_size = 4*window_size;

% Calculate the spectrogram window (Gaussian).
window = exp(-[-fft_size/2+1:fft_size/2].'.^2/(2*(window_size/4)^2));

% Calculate the spectrogram.
spec = zeros(fft_size, floor(length(x)/hop_size)+1);
for k = 1:size(spec,2)
	x_shift = circshift(x, -(k-1)*hop_size);
	spec(:,k) = abs(fft(x_shift(1:fft_size).*window));
end
spec = spec(1:end/2,:);
spec = circshift(spec, [0 round(fft_size/(2*hop_size))]);

% Prepare the (approximate) mel-scale filters.
filt_opt.B = 8;
filt_opt.Q = 16*filt_opt.B;
filt_opt.J = T_to_J(128, filt_opt);
filt_opt.boundary = 'per';

filters = filter_bank(fft_size, filt_opt);

% Extract the Fourier transform coefficients and assemble them into a table.
psi_f = cellfun(@realize_filter, filters{1}.psi.filter, 'UniformOutput', 0);
psi_f = [psi_f{:}];

% Determine which filter is dominant at a particular frequency. This gives a
% mapping from the frequency scale to the filter (~mel) scale.
[temp,I] = max(psi_f,[],2);

% Calculate mel-frequency spectrum by averaging spectrogram along frequency.
melspec = psi_f(1:end/2,I(1:end/2))'*spec;

% Calculate positions of slices.
sl1 = round(size(spec,2)/4);
sl2 = round(3*size(spec,2)/4);

% Compute the logarithm.
spec = log(spec+1);
melspec = log(melspec+1);

% Display the spectrogram and mel-frequency spectrogram.
figure(1);
clf;
set(gcf,'Units','inches','Position',[3 3 8 1.2]);
ax_spec = axes('Units','inches','Position',[0.50 0.24 3.10 0.72]);
imagesc(spec);
set(gca,'YDir','normal');
set(gca,'YTick',[]);
set(gca,'XTick',[]);
ax_spec = axes('Units','inches','Position',[3.80 0.24 0.30 0.72]);
plot(spec(:,sl1),1:fft_size/2,'b', ...
	spec(:,sl2),1:fft_size/2,'r');
set(gca,'YTick',[]);
set(gca,'XTick',[]);
ylim([1 fft_size/2]);
ax_spec = axes('Units','inches','Position',[4.30 0.24 3.10 0.72]);
imagesc(melspec);
set(gca,'YDir','normal');
set(gca,'YTick',[]);
set(gca,'XTick',[]);
ax_spec = axes('Units','inches','Position',[7.60 0.24 0.30 0.72]);
plot(melspec(:,sl1),1:fft_size/2,'b', ...
	melspec(:,sl2),1:fft_size/2,'r');
set(gca,'YTick',[]);
set(gca,'XTick',[]);
ylim([1 fft_size/2]);

