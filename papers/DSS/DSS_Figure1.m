x = wavread('dilation.wav');

window_size = 128;
hop_size = window_size/32;
fft_size = 4*window_size;

window = exp(-[-fft_size/2+1:fft_size/2].'.^2/(2*(window_size/4)^2));

spec = zeros(fft_size, floor(length(x)/hop_size)+1);

for k = 1:size(spec,2)
	x_shift = circshift(x, -(k-1)*hop_size);
	spec(:,k) = abs(fft(x_shift(1:fft_size).*window));
end
spec = spec(1:end/2,:);
spec = circshift(spec, [0 round(fft_size/(2*hop_size))]);

filt_opt.B = 8;
filt_opt.Q = 16*filt_opt.B;
filt_opt.J = T_to_J(128, filt_opt);
filt_opt.boundary = 'per';

filters = filter_bank(fft_size, filt_opt);

psi_f = cellfun(@realize_filter, filters{1}.psi.filter, 'UniformOutput', 0);
psi_f = [psi_f{:}];

[~,I] = max(psi_f,[],2);

melspec = psi_f(1:end/2,I(1:end/2))'*spec;

sl1 = round(size(spec,2)/4);
sl2 = round(3*size(spec,2)/4);

spec = log(spec+1);
melspec = log(melspec+1);

figure;
subplot(1,10,1:4);
imagesc(spec);
set(gca,'YDir','normal');
set(gca,'YTick',[]);
set(gca,'XTick',[]);
subplot(1,10,5);
plot([spec(:,sl1) spec(:,sl2)],1:fft_size/2);
set(gca,'YTick',[]);
set(gca,'XTick',[]);
ylim([1 fft_size/2]);
subplot(1,10,6:9);
imagesc(melspec);
set(gca,'YDir','normal');
set(gca,'YTick',[]);
set(gca,'XTick',[]);
subplot(1,10,10);
plot([melspec(:,sl1) melspec(:,sl2)],1:fft_size/2);
set(gca,'YTick',[]);
set(gca,'XTick',[]);
ylim([1 fft_size/2]);
