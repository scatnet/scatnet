% image_scat_layer : return scattering outputs images next to each other
%
% Usage
%	image_scat_layer(S{3}) return all the images of the third layer
%	of scattering S embeded next to each other in a large image
%	with their meta in the upper left hand corner
%	
% Input
%	Scatt : <struct> a layer of a scattering (either U or S)
%	renorm : <1x1 int> [default = 1] if 1 renormalize each path by its max
%	dsp_legend <1x1 int> [default = 1] if 1 display legend
%
% Output
%	big_img : <?x? double> a large image where all path are concatenated

function [] = image_scat(S, renorm, dsp_legend)
	
	for m = 1:numel(S);
		figure(m);
		switch (nargin)
			case 1
				big_img = image_scat_layer(S{m});
				
			case 2
				big_img = image_scat_layer(S{m}, renorm);
				
			case 3
				big_img = image_scat_layer(S{m}, renorm, dsp_legend);
				
		end
		imagesc(big_img);
	end
end