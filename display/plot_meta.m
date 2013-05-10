% plot_meta : plot all the meta of all orders of the scattering
%
% Usage 
%   plot_meta(S) display a matrix of plot. Each column of this matrix
%		corresponds to a scattering order. Each column of this matrix
%		corresponds to a meta field (e.g. j, theta) 
%
% Input
%	S : <1x? cell> the output of scat 

function plot_meta(S)
	
	% compute number of subplot
	M = numel(S);
	nb_row = 0;
	for m = 1:M
		fn = fieldnames(S{m}.meta);
		nb_row = max(nb_row, numel(fn));
	end
	nb_column = M;
	
	
	for m = 1:M
		plot_meta_layer(S{m}.meta, m, nb_row, nb_column);
	end
	
end