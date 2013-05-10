function x = unpad_signal_1d(x,res,N0)
	dims = ndims(x);
	for d = 1:length(N0)
		N2 = 1+floor((N0(d)-1)/2^res(d));
		
		%x = shiftdim(x,d-1);
		%sz = size(x);
		%x = reshape(x,[sz(1) prod(sz(2:end))]);
		%x = x(1:N2,:);
		%x = reshape(x,[N2 sz(2:end)]);
		%x = shiftdim(x,dims-d+1);
		
		% MATLAB is stupid; easier to do manually
		if d == 1
			x = x(1:N2,:,:);
		elseif d == 2
			x = x(:,1:N2,:);
		end
	end
end
