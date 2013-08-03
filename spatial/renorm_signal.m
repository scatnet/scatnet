function [x_rn, tmp] = renorm_signal(x, h, K, method)
	tmp = x;
	switch (method)
		case 'iterate'
			% apply K times h to compute renormalization factor
			for k = 1:K
				tmp = convsub2d_spatial(tmp, h, 0);
			end
		case 'cascade'
			% cascade K times h and interpolate
			% to compute renormalization factor
			for k = 1:K
				tmp = convsub2d_spatial(tmp, h, 1);
			end
			tmp = imresize_notoolbox(tmp, size(x));
		otherwise
			error('unkown renormalization method');
	end
	x_rn = x./tmp;
end