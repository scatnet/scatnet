% PLOT_LITTLEWOOD_PALEY_1D Plot Littlewood-Paley
%
% Usage
%    lp = plot_littlewood_1d(filters)
%
% Input
%    filters (struct):
%
% Description
%    \sum_{j, \theta} |\hat{\psi_j} (\omega)|^2 + |\hat{\phi_J}(\omega)|^2
%
% See also
%   DISPLAY_FILTER_2D, MORLET_FILTER_BANK_1D

function littlewood = plot_littlewood_paley_1d(filters)
hold on;
for j = 1:numel(filters.psi.filter)
    psi = realize_filter(filters.psi.filter{j});
    psi_squared = abs(psi).^2/2;
    plot(psi_squared, 'Color', [0, 0, 0.8]);
    if (j == 1)
        littlewood = psi_squared;
    else
        littlewood = littlewood + psi_squared;
    end
    psi_squared_flip(1) = psi_squared(1);
    psi_squared_flip(2:numel(psi_squared)) = psi_squared(end:-1:2);
    if sum((size(psi_squared_flip)-size(psi_squared))~=0)
        psi_squared_flip = psi_squared_flip';
    end
    littlewood = littlewood + psi_squared_flip;
end
phi = realize_filter(filters.phi.filter);
phi_squared = abs(phi).^2;
littlewood = littlewood + phi_squared;
plot(phi_squared, 'Color', [0, 0.8, 0]);
plot(littlewood, 'Color', [0.8, 0, 0]);
hold off;
end

