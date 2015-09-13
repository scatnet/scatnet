% CONVOLVE Perform convolution of vectors
%
% Usage
%    z = convolve(x, y);
%

function z = convolve(x, y, dim, boundary)
	if nargin < 3 || isempty(dim)
		dim = 1;
	end

	if nargin < 4 || isempty(boundary)
		boundary = 'zero';
	end

	if dim ~= 1
		error('only convolution along first dimension is supported');
	end

	boundary_type = find(strcmp(boundary, {'zero', 'symm', 'per'}));

	if isempty(boundary_type)
		error(['invalid boundary parameter ''' boundary '''']);
	end

	x_sz = size(x);
	x = reshape(x, size(x, 1), []);

	z = zeros(size(x), class(x));

	x_len = size(x, 1);
	y_len = size(y, 1);

	y_mid = ceil((y_len+1)/2);

	for n = 1:x_len
		x_ind = [n-(y_len-y_mid):n+y_mid-1];

		if boundary_type == 1
			x_ind(x_ind<1) = [];
			x_ind(x_ind>x_len) = [];
			y_ind = y_mid+(n-x_ind);
		elseif boundary_type == 2
			x_ind = mod(x_ind-1, 2*x_len)+1;
			ind_map = [1:x_len x_len:-1:1];
			x_ind = ind_map(x_ind);
			y_ind = y_len:-1:1;
		elseif boundary_type == 3
			x_ind = mod(x_ind-1, x_len)+1;
			y_ind = y_len:-1:1;
		end

		z(n,:) = sum(bsxfun(@times, ...
			x(x_ind,:), y(y_ind,:)), 1);
	end

	z = reshape(z, x_sz);
end

