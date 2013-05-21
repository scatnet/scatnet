clear;

N = 16;

phif = [1, zeros(1,N-1)];

psif{1} = [0,1/sqrt(2),1,1/sqrt(2), zeros(1,N-4) ];
psif{2} = [0,		 0,0,1/sqrt(2),1,1,1/sqrt(2),zeros(1,N-6)];
psif{3} = [0,		 0,0,		 0,0,0,1/sqrt(2),1,1,1,1,1/sqrt(2),zeros(1,N-11)];

%%
filters = meyer_filter_bank_1d_16();

plot_littlewood_1d(filters);
%% plot in fourier
clf;
hold on;
plot(phif,'Color', [0, 0.8, 0.0]);
for j = 1:3
	plot(psif{j},'Color', [0, 0, 0.8]);
end
hold off;

%% plot in spatials


plot_spatial = @(xf)(plot([real(ifft(xf));imag(ifft(xf))]'));

clf;
subplot(411);
plot_spatial(phif);
for j = 1:3
	subplot(4,1,j+1);
	plot_spatial(psif{j});
end