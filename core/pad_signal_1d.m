function x = pad_signal_1d(x,N1,boundary)
	for d = 1:length(N1)
		N0 = size(x,d);
	
		if strcmp(boundary,'symm')
			ind0 = [1:N0 N0:-1:1];
		elseif strcmp(boundary,'per')
			ind0 = [1:N0];
		else
			error('Invalid boundary conditions!');
		end
	
		ind = zeros(1,N1(d));
		ind(1:N0) = 1:N0;
		ind(N0+1:N0+floor((N1(d)-N0)/2)) = ...
			ind0(mod([N0+1:N0+floor((N1(d)-N0)/2)]-1,length(ind0))+1);
		ind(N1(d):-1:N0+floor((N1(d)-N0)/2)+1) = ...
			ind0(mod([1:ceil((N1(d)-N0)/2)]-1,length(ind0))+1);
	
		x = shiftdim(x,d-1);
		x = x(ind,:);
		x = shiftdim(x,ndims(x)-d+1);
	end
end