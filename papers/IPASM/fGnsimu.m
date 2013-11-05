% Simulates a fractional gaussian noise of size N and Hurst exponent H
% Returns the vector B^H(1) - B^H(0), ..., B^H(size) - B^H(size-1) where B^H is a fractional Brownian motion with Hurst exponent H
function x = fGnsimu(N,H)

	correl = .5*((0:N-1).^(2*H) + (2:N+1).^(2*H) - 2*(1:N).^(2*H));
	x =gaussprocess([1 correl],N);
