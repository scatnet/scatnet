function x_conv_y = conv_sub_unpad_2d(xf, filter, ds, margin)
	x_conv_y_tmp = conv_sub_2d(xf, filter, ds);
	
	x_conv_y = x_conv_y_tmp(1:end-margin(1), 1:end-margin(2));
end