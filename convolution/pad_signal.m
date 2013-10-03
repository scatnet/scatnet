function x = pad_signal(x,N1,boundary,half_sample)
	if nargin < 3 || isempty(boundary)
		boundary = 'symm';
	end
	
	if nargin < 4 || isempty(half_sample)
		half_sample = 1;
	end
		
	has_imag = norm(imag(x(:)))>0;
	
	for d = 1:length(N1)
		N0 = size(x,d);
	
		if strcmp(boundary,'symm')
			if half_sample
				ind0 = [1:N0 N0:-1:1];
				conjugate0 = [zeros(1,N0) ones(1,N0)];
			else
				ind0 = [1:N0 N0-1:-1:2];
				conjugate0 = [zeros(1,N0) ones(1,N0-2)];
			end
		elseif strcmp(boundary,'per')
			ind0 = [1:N0];
			conjugate0 = zeros(1,N0);
		elseif strcmp(boundary,'zero')
			ind0 = [1:N0];				% UNUSED FOR NOW
			conjugate0 = zeros(1,N0);
		else
			error('Invalid boundary conditions!');
		end
	
		if ~strcmp(boundary,'zero')
			ind = zeros(1,N1(d));
			conjugate = zeros(1,N1(d));
			ind(1:N0) = 1:N0;
			conjugate(1:N0) = zeros(1,N0);
			src = mod([N0+1:N0+floor((N1(d)-N0)/2)]-1,length(ind0))+1;
			dst = N0+1:N0+floor((N1(d)-N0)/2);
			ind(dst) = ind0(src);
			conjugate(dst) = conjugate0(src);
			src = mod(length(ind0)-[1:ceil((N1(d)-N0)/2)],length(ind0))+1;
			dst = N1(d):-1:N0+floor((N1(d)-N0)/2)+1;
			ind(dst) = ind0(src);
			conjugate(dst) = conjugate0(src);
		else
			ind = 1:N0;
			conjugate = zeros(1,N0);
		end
	
		%x = shiftdim(x,d-1);
		%sz = size(x);
		%x = reshape(x,[sz(1) prod(sz(2:end))]);
		%x = x(ind,:);
		%x = reshape(x,[length(ind) sz(2:end)]);
		%x = shiftdim(x,dims-d+1);
		
		% MATLAB is stupid; easier to do manually
		if d == 1
			x = x(ind,:,:);
			if has_imag
				x = x-2*i*bsxfun(@times,conjugate.',imag(x));
			end
			if strcmp(boundary,'zero')
				x(N0+1:N1,:,:) = 0;
			end
		elseif d == 2
			x = x(:,ind,:);
			if has_imag
				x = x-2*i*bsxfun(@times,conjugate,imag(x));
			end
			if strcmp(boundary,'zero')
				x(:,N0+1:N1,:) = 0;
			end
		end
	end
end