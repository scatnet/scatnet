function x_conv_y = conv_sub_2d(xf, filter, ds)
	if (isnumeric(filter))
		x_conv_y = ifft2(sum(extract_block(xf .* filter, [2^ds, 2^ds]), 3)) / 2^ds;
	elseif isstruct(filter) && strcmp(filter.type,'fourier_multires')
		res = log2(size(filter.coefft{1},1)/size(xf,1));
		x_conv_y = conv_sub_2d(xf, filter.coefft{res+1}, ds);
	end
end