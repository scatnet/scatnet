% CONVOLVE Perform convolution of vectors
%
% Usage
%    z = convolve(x, y);
%

function z = convolve(x, y)
	x_sz = size(x);
	x = reshape(x, size(x, 1), []);

	z = zeros(size(x), class(x));

	x_len = size(x, 1);
	y_len = size(y, 1);

	y_mid = ceil((y_len+1)/2);

	for n = 1:x_len
		x_ind = [max(1, n-(y_len-y_mid)) min(x_len, n+y_mid-1)];
		y_ind = y_mid+(n-x_ind);
		z(n,:) = sum(bsxfun(@times, ...
			x(x_ind(1):x_ind(2),:), y(y_ind(1):-1:y_ind(2),:)), 1);
	end

	z = reshape(z, x_sz);
end

