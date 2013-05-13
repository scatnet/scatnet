% plot_meta_layer : Plot the meta variables of a layer of scattering
%
% Usage
%    S = scat(x, wavelet);
%    plot(S{3}.meta); will plot the meta variables of the third layer of
%    scattering S
% 
% Input
%    meta : <struct> containing arrays of value
%      - j : <?x?> each column contains the successive scales of wavelet 
%
% Output
%    no output

function plot_meta_layer(meta, m, nb_row, nb_column)
	fn=fieldnames(meta);
	
	if (nargin<2)
		m = 1;
		nb_row = numel(fn);
		nb_column = 1;
	end
	
	
	
	for i=1:numel(fn)
		subplot(nb_row,nb_column, m + nb_column*(i-1));
		vec2plot=eval(['meta.',fn{i}]);
		plot(vec2plot');
		s = regexprep(fn{i}, '_', '');
		xlabel('p');
		ylabel(s);
	end
	
	
end