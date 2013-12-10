% Generate Figure 3 of the "Deep Scattering Spectrum" paper.

% Set up filter options.
N = 2^10;
filt_opt.filter_type = 'morlet_1d';
filt_opt.Q = 8;
filt_opt.J = T_to_J(128, filt_opt);

% Create filter bank.
filters = filter_bank(N, filt_opt);

% Extract wavelets psi in Fourier domain.
psi_f = cellfun(@realize_filter, filters{1}.psi.filter, 'UniformOutput', 0);
psi_f = [psi_f{:}];
psi_f = bsxfun(@times, psi_f, 1./max(psi_f,[],1));

% Extract lowpass phi in Fourier domain.
phi_f = realize_filter(filters{1}.phi.filter);

% Set up figure dimensions.
figure(3);
clf;
set(gcf, 'Units', 'inches', 'Position', [3 3 3.5 0.6]);
axes('Units', 'inches', ...
	'Position', [0.05 0.05 3.5-0.1 0.6-0.1]);

% Plot psis and phi.
figure(3);
plot(1:size(psi_f,1), phi_f, 'r', ...
	1:size(psi_f,1),psi_f,'b');

% Set axis ranges.
ylim([0 max(psi_f(:))*1.2]);
xlim([1 size(psi_f,1)/2*1.1]);

% Remove axis ticks.
set(gca,'XTick',[]);
set(gca,'YTick',[]);

