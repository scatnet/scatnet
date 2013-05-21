function [] = plot_littlewood_1d( filters )
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
		psi_squared_flip(1) = psi_squared(1);
		psi_squared_flip(2:numel(psi_squared)) = psi_squared(end:-1:2);
		if sum((size(psi_squared_flip)-size(psi_squared))~=0)
			psi_squared_flip = psi_squared_flip';
		end
		litllewood = litllewood + psi_squared_flip;
	end
	phi = realize_filter(filters.phi.filter);
	phi_squared = abs(phi).^2;
	litllewood = litllewood + phi_squared;
	plot(phi_squared, 'Color', [0, 0.8, 0]);
	plot(litllewood, 'Color', [0.8, 0, 0]);
	hold off;
end

