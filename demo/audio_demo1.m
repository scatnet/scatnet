% Load a familiar tune & truncate to the first N samples.
N = 65536;
load handel;
y = y(1:N);

% Set up default filter bank with averaging scale of 4096 samples.
T = 4096;
filt_opt = default_filter_options('audio', T);

% Only compute zeroth-, first- and second-order scattering.
scat_opt.M = 2;

% Prepare wavelet transforms to use in scattering.
[Wop, filters] = wavelet_factory_1d(N, filt_opt, scat_opt);

% Display first- and second-order filter banks
figure;
for m = 1:2
	subplot(1,2,m);
	hold on; 
	for k = 1:length(filters{m}.psi.filter)
		plot(realize_filter(filters{m}.psi.filter{k}, N)); 
	end
	hold off;
	ylim([0 1.5]);
	xlim([1 5*N/8]);
end

%%
% Compute the scattering coefficients of y.
S = scat(y, Wop);
%%
% Display first-order coefficients, as a function of time and scale j1, and
% second-order coefficients for a fixed j1, as a function of time and second
% scale j2.
img{1} = scattergram_layer(S{1+1},[]);
j1 = 23;
img{2} = scattergram_layer(S{1+2},j1);
time = (1:size(img{1},2))/size(img{1},2) * N/Fs;

figure;
title('Scattergram of first and second-order coefficients');
subplot(2,1,1);
imagesc(time,1:size(img{1},1),img{1});
xlabel('Time (s)');
ylabel('Scale number j1');
colorbar;
subplot(2,1,2);
imagesc(time,1:size(img{2},1),img{2});
xlabel('Time (s)');
ylabel('Scale number j1');
colorbar;

% Set the colormap to inverted grayscale for potential ink saving.
colormap(1-colormap(gray));

%%
% Renormalize second order by dividing it by the first order and compute the
% logarithm of the coefficients.
logrenorm_S = log_scat(renorm_scat(S));

% Display the transformed coefficients.
img_logrenorm{1} = scattergram_layer(logrenorm_S{1+1},[]);
j1 = 23; % arbitrary choice
img_logrenorm{2} = scattergram_layer(logrenorm_S{1+2},j1);
time = (1:size(img_logrenorm{1},2))/size(img_logrenorm{1},2) * N/Fs;

figure;
title('Scattergram of log_renormalized coefficients');
subplot(2,1,1);
imagesc(time,1:size(img_logrenorm{1},1),img_logrenorm{1});
xlabel('Time (s)');
ylabel('Scale number j1');
colorbar;
subplot(2,1,2);
imagesc(time,1:size(img_logrenorm{2},1),img_logrenorm{2});
xlabel('Time (s)');
ylabel('Scale number j2');
colorbar;
colormap(1-colormap(gray));