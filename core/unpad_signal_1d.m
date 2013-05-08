function x = unpad_1d(x,res,N0)
	for d = 1:length(N0)
		N2 = 1+floor((N0(d)-1)/2^res(d));
		
		x = shiftdim(x,d-1);
		x = x(1:N2,:);
		x = shiftdim(x,ndims(x)-d+1);
	end
end
