% IMAGE_SCAT return scattering outputs images next to each other
%
% Usage
%   IMAGE_SCAT(S, renorm, dsp_legend)
%	
% Input
%	Scatt (cell): layers of  scattering (either U or S)
%	renorm (boolean): if 1 renormalize each path by its max. Default
%	value is set to 1.
%	dsp_legend (boolean): if set to 1, display legend. Default value is 1
%
% Description
%	Display the scattering coefficients in an image. Concerning the third 
%   layer, thescattering coefficients are embeded next to each other in a 
%   large image with their meta in the upper left hand corner
%
% See also
%   IMAGE_SCAT_LAYER

function image_scat(S, renorm, dsp_legend)
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