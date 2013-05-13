function phi = periodic_gaussian_1d(N, sigma)
	
	% compute wavelet on large support NN and periodize them to avoid
	% boundary effects
	nb_block = 16;
	NN = N*nb_block;
	x = 1:NN;
	x = x - ceil(NN/2) - 1;
	
	phi = 1/(sqrt(2*pi)*sigma) .* ...
		exp( - x.^2 / (2*sigma^2) );
	
	% periodize
	phi = sum(reshape(phi, N, nb_block),2);
end