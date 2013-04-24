function X = unpad_layer_1d(X,N0)
	for j1 = 0:length(X.signal)-1
		for d = 1:length(N0)
			if isfield(X.meta, 'resolution')
				N2 = 1+floor((N0(d)-1)/2^X.meta.resolution(d,j1+1));
			else
				N2 = N0(d);
			end
			
			temp = shiftdim(X.signal{j1+1},d-1);
			temp = temp(1:N2,:);
			temp = shiftdim(temp,ndims(temp)-d+1);
			X.signal{j1+1} = temp;
	end
end