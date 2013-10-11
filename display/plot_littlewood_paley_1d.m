% PLOT_LITTLEWOOD_PALEY_1D Plot Littlewood-Paley sum of a filter bank
%
% Usage
%    littlewood = plot_littlewood_paley_1d(filters);
%
% Input
%    filters (struct): filter bank (see FILTER_BANK)
%
% Description
%    This function computes, at every frequency, the Littlewood-Paley sum
%    of the filter bank, i.e. the total power spectral density
%    \sum_{j, \theta} |\hat{\psi_j} (\omega)|^2 + |\hat{\phi_J}(\omega)|^2
%    If this sum is between (1-epsilon) and 1 for small epsilon, the
%    associated wavelet transform is proved to be contractive and almost
%    unitary.
%
% See also
%    LITTLEWOOD_PALEY, DISPLAY_LITTLEWOOD_PALEY_2D, FILTER_BANK

function littlewood = plot_littlewood_paley_1d(filters)
	rgb_red = [0.8,0,0];
	rgb_green = [0.1,0.6,0.1];
	rgb_blue = [0,0,0.8];

	hold on;
	littlewood = littlewood_paley(filters);

	plot(littlewood, 'Color', rgb_red);

	for j=1:numel(filters.psi.filter)
	    psi = realize_filter(filters.psi.filter{j});
	    psi_squared = abs(psi).^2/2;
	    plot(psi_squared,'Color',rgb_blue);
	end

	phi = realize_filter(filters.phi.filter);
	phi_squared = abs(phi).^2;

	plot(phi_squared, 'Color', rgb_green);

	legend('Littlewood-Paley sum','Lowpass filter','Bandpass filters');
	xlabel('Samples');
	ylabel('Amplitude');
	hold off;
end

