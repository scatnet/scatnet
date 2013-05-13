function psi = periodic_morlet_1d(N, sigma, xi)
	
	% compute wavelet on large support NN and periodize them to avoid
	% boundary effects
	nb_block = 16;
	NN = N*nb_block;
	x = 1:NN;
	x = x - ceil(NN/2) - 1;
	
	gaussian = exp( - x.^2 / (2*sigma^2) );
	psi = 1/(sqrt(2*pi)*sigma) .* ...
		gaussian .* ...
		exp( - 1i * xi * x );
	% morlet removes the enveloppe to enforce zero average
	psi = psi - sum(psi(:)) / sum(gaussian(:)) * gaussian;
	
	% periodize
	psi = sum(reshape(psi, N, nb_block),2);

end
