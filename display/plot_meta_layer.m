% PLOT_META_LAYER : Plot the meta variables of a layer of scattering
%
% Usage
%     PLOT_META_LAYER(meta, m, nb_row, nb_column)
% 
% Input
%    meta (struct): structure with array of value
%    m (numerical): indice of the layer
%    nb_row (numerical): number of row for the subplot
%    nb_column (numerical): number of column for the subplot
% 
% Description
%    Auxiliar function for plot_meta to print any structures
%
% See also
%    PLOT_META_LAYER

function plot_meta_layer(meta, m, nb_row, nb_column)
	fn=fieldnames(meta);
	
	if (nargin<2)
		m = 1;
		nb_row = numel(fn);
		nb_column = 1;
    end

    % Display meta
	for i=1:numel(fn)
		subplot(nb_row,nb_column, m + nb_column*(i-1));
		vec2plot=eval(['meta.',fn{i}]);
		plot(vec2plot');
		s = regexprep(fn{i}, '_', '');
		xlabel('p');
		ylabel(s);
    end
end