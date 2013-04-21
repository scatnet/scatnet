function y = conv_sub_1d(xf,filter,ds)
	if isnumeric(filter)
		N = size(filter,1);
		j0 = log2(N/size(xf,1));
		filter_per = sum(reshape(filter,[N/2^j0 2^j0]),2);
		yf = bsxfun(@times,xf,filter_per);
		yf = sum(reshape(yf,[size(yf,1)/2^ds 2^ds size(yf,2)]),2)/2^(ds/2);
		yf = reshape(yf,[size(yf,1) size(yf,3)]);
		y = ifft(yf,[],1);
	elseif isstruct(filter) && strcmp(filter.type,'fourier_multires')
		N = filter.N;
		j0 = log2(N/size(xf,1));
		yf = bsxfun(@times,xf,filter.coefft{j0+1});
		yf = sum(reshape(yf,[size(yf,1)/2^ds 2^ds size(yf,2)]),2)/2^(ds/2);
		yf = reshape(yf,[size(yf,1) size(yf,3)]);
		y = ifft(yf,[],1);
	elseif isstruct(filter) && strcmp(filter.type,'fourier_truncated')
		N = filter.N;
		j0 = log2(N/size(xf,1));
		j1 = log2(N/length(filter.coefft));
		ds = ds+j0-j1;
		if j0 > j1
			% TODO make this more efficient
			xf = [xf(1:end/2,:); zeros(N*(2^(-j1)-2^(-j0)),size(xf,2)); xf(end/2+1:end,:)];
			xf = xf*sqrt(2^(j0-j1));
			j0 = j1;
		end
		% WARNING: start is 1-based, not 0-based
		if filter.start <= 0
			ind = [N/2^j0+filter.start:N/2^j0 1:length(filter.coefft)+filter.start-1];
		else
			ind = [1:length(filter.coefft)]+filter.start-1;
		end
		yf = bsxfun(@times,xf(ind,:),filter.coefft);
		if ds > 0
			yf = reshape( ...
				sum(reshape(yf,[size(yf,1)/2^ds 2^ds size(yf,2)]),2), ...
				[size(yf,1)/2^ds size(yf,2)]);
		elseif ds < 0
			yf = [yf; zeros((2^(-ds)-1)*size(yf,1),size(yf,2))];
		end
		if filter.recenter
			yf = circshift(yf,filter.start-1);
		end
		yf = yf/sqrt((N/2^j0)/size(yf,1));
		y = ifft(yf,[],1);
	else
		error('Unsupported filter type!');
	end
end