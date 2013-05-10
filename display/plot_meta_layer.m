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

function plot_meta_layer(meta)
	
	fn=fieldnames(meta);
	
	for i=1:numel(fn)
		subplot(numel(fn),1,i);
		vec2plot=eval(['meta.',fn{i}]);
		plot(vec2plot');
		s = regexprep(fn{i}, '_', '');
		xlabel('p');
		ylabel(s);
	end
	
	
end