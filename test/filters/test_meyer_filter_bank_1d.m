clear;


%%
filters = meyer_filter_bank_1d_16();


%% plot in fourier
clf
plot_littlewood_1d(filters);

%% plot in spatials
plot_spatial = @(xf)(plot([real(ifft(xf));imag(ifft(xf))]'));

clf;
subplot(411);
plot_spatial(filters.phi.filter);
for j = 1:3
	subplot(4,1,j+1);
	plot_spatial(filters.psi.filter{j});
end