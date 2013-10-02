% DISPLAY_LITTLEWOOD_PALEY_2D Display Littlewood-Paley sum of a filter bank
%
% Usage
%    littlewood = display_littlewood_paley_2d(filters);
%
% Input
%    filters (struct): filter bank (see FILTER_BANK)
%
% Description
%    The function computes the Littlewood-Paley sum of the filter bank and 
%    displays it. It also outputs the sum.
% See also
%   LITTLEWOOD_PALEY, PLOT_LITTLEWOOD_PALEY_1D, FILTER_BANK

function littlewood = display_littlewood_paley_2d(filters)
	lp = littlewood_paley(filters);
	img = fftshift(lp);
	imagesc(img);
end