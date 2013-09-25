function YconvZ = roto_trans_conv(Y, Yftheta, z1, z2, theta2, q, dstheta)
	
	L = z2.N/2;
	
	if (numel(z1)==0)
		% no conv with z1 since it is a dirac
		% convolution with z2
		if (2^dstheta == 2*L)
			% faster to compute the sum if there is only one sample left
			YconvZ = sum(Y, 3) / 2^(ds/2);
		else
			YconvZ = sub_conv_1d_along_third_dim_simple(Yftheta, z2, dstheta);
		end
	else
		% convolution with z1
		for theta = 1:L
			theta_sum_mod2L =  1 + mod(theta + theta2 - 2, 2*L);
			theta_sum_modL  =  1 + mod(theta + theta2 - 2, L);
			tmp_slice = conv_sub_2d(Y(:,:,theta), z2{theta_sum_modL + L*q}, 0);
			if (theta == 1) % allocate when size is known
				YconvZ1 = prec(zeros([size(tmp_slice), 2*L]));
			end
			if (theta_sum_mod2L <= L)
				YconvZ1(:,:,theta)   = tmp_slice;
				YconvZ1(:,:,theta+L) = conj(tmp_slice);
			else
				YconvZ1(:,:,theta)   = conj(tmp_slice);
				YconvZ1(:,:,theta+L) = tmp_slice;
			end
		end
		% convolution with z2
		if (2^dstheta == 2*L)
			% faster to compute the sum along the angle
			YconvZ = sum(tmp, 3) / 2^(ds/2);
		else
			tmp_f = fft(tmp, [], 3);
			YconvZ = ...
				sub_conv_1d_along_third_dim_simple(tmp_f, phi_angle, ds);
		end
	end
	
end
