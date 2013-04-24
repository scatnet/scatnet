function X = pad_layer_1d(X,N1,boundary)
	for d = 1:length(N1)
		N0 = size(X.signal{1},d);
	
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
	
		for j1 = 0:length(X.signal)-1
			temp = shiftdim(X.signal{j1+1},d-1);
			temp = temp(ind,:);
			temp = shiftdim(temp,ndims(temp)-d+1);
			X.signal{j1+1} = temp;
		end
	end
end
