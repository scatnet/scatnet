% convolve x with filterfilter and subsample by 2^ds
function x_conv_psi_unpad_sub = conv_sub_2d(x, filter, ds)
	if (strcmp(filter.type,'spatial_support'))
		filt = filter.coefft;
		P = floor(size(filt,1)/2);
		x_paded = pad_mirror_2d_twosided(x, [P, P]);
		x_conv_psi = conv2(x_paded, filt, 'same');
		%x_conv_psi_unpad = x_conv_psi(1+P:end-P, 1+P:end-P);
		%x_conv_psi_unpad_sub = 1/2^ds * x_conv_psi_unpad(1:2^ds:end,1:2^ds:end);
		x_conv_psi_unpad_sub = 2^ds * x_conv_psi(1+P:2^ds:end-P, 1+P:2^ds:end-P); 
	elseif (strcmp(filter.type,'spatial_support_separable'))
		P = floor(numel(filter.coefft{1})/2);
		x_paded = pad_mirror_2d_twosided(x, [P, P]);
		x_conv_psi = conv2(filter.coefft{1}, filter.coefft{2}, x_paded, 'same'); 
		% for some reason it is slower that the non-separable version...
		%x_conv_psi = conv2dsep(x_paded, filt2, filt1);
		x_conv_psi_unpad = x_conv_psi(1+P:end-P, 1+P:end-P);
		x_conv_psi_unpad_sub = 2^ds * x_conv_psi_unpad(1:2^ds:end,1:2^ds:end);
	else
		error('unsupported filter. use spatial filters defined on its support');
	end
end
