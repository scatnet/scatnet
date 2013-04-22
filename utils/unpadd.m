function x_unpadded=unpadd(x, size_padded_original, margin)
	margin_out = floor(margin .* (size(x)./size_padded_original) );
	x_unpadded = x(1+margin_out(1):end-margin_out(1),...
		1+margin_out(2):end-margin_out(2));
end