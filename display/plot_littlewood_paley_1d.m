% PLOT_LITTLEWOOD_PALEY_1D Plot Littlewood-Paley sum of a filter bank
%
% Usage
%    littlewood = plot_littlewood_1d(filters);
%
% Input
%    filters (struct): filter bank (see FILTER_BANK)
%
% Description
%    This function computes, at every frequency, the Littlewood-Paley sum
%    of the filter bank, i.e. the total power spectral density
%    \sum_{j, \theta} |\hat{\psi_j} (\omega)|^2 + |\hat{\phi_J}(\omega)|^2
%    If this sum is between (1-epsilon) and 1, the associated wavelet
%    transform is proved to be contractive and almost unitary.
%    NB : this function has a 2D counterpart, namely DISPLAY_FILTER_2D.
% See also
%   DISPLAY_FILTER_2D, FILTER_BANK

function littlewood = plot_littlewood_paley_1d(filters)
rgb_red = [0.8,0,0];
rgb_green = [0.1,0.6,0.1];
rgb_blue = [0,0,0.8];

hold on;
for j = 1:numel(filters.psi.filter)
    psi = realize_filter(filters.psi.filter{j});
    psi_squared = abs(psi).^2/2;
    plot(psi_squared, 'Color', rgb_blue);
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
plot(phi_squared, 'Color', rgb_green);
plot(littlewood, 'Color', rgb_red);
hold off;
end

