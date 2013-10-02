%% Demo of *plot_meta*
% We show some examples on the use of *plot_meta*. It displays graphically
% information about the scattering transform parameters.
%
%% Usage
%  *plot_meta*(S) and *plot_meta_layer*(meta, m, nb_row, nb_column)
%
%% Examples
x = lena;
[Wop, filters] = wavelet_factory_2d(size(x));
[S, U] = scat(x, Wop);

plot_meta(S);

