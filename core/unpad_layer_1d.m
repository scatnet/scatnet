function X = unpad_layer_1d(X,N0)
	for j1 = 0:length(X.signal)-1
		if isfield(X.meta, 'resolution')
			N2 = 1+floor((N0-1)/2^X.meta.resolution(j1+1));
		else
			N2 = N0;
		end
		X.signal{j1+1} = X.signal{j1+1}(1:N2,:);
		
	end
end