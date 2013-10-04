%% Demo of *display_filter_2d* and *display_filter_bank_2d*
% The display filter functions returns an image corresponding to the filter
% display in spatial domain.
%
%% Usage
%  *plot_meta*(S) and *plot_meta_layer*(meta, m, nb_row, nb_column)
%
%% Examples
x = lena;
[Wop, filters] = wavelet_factory_2d(size(x));
[S, U] = scat(x, Wop);

plot_meta(S);

