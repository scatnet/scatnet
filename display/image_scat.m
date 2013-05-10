function [] = image_scat(S)
	for m = 1:numel(S);
		figure(m);
		big_img = image_scat_layer(S{m});
		imagesc(big_img);
	end
end