function [] = plot_littlewood_1d( filters )
	clf;
	hold on;
	for j = 1:numel(filters.psi.filter)
		psi = realize_filter(filters.psi.filter{j});
		psi_squared = abs(psi).^2/2;
		plot(psi_squared, 'Color', [0, 0, 0.8]);
		if (j == 1)
			litllewood = psi_squared;
		else
			litllewood = litllewood + psi_squared;
		end
	end
	phi = filters.phi.filter.coefft{1};
	phi_squared = abs(phi).^2;
	litllewood = litllewood + phi_squared;
	plot(phi_squared, 'Color', [0, 0.8, 0]);
	plot(litllewood, 'Color', [0.8, 0, 0]);
	hold off;
end

