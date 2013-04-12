function [U,S] = wavemod_1d(in,filters,options)
	if nargin < 3
		options = struct();
	end

	options = fill_struct(options,'antialiasing',1);
	
	[psi_xi,psi_bw,phi_bw] = filter_freq(filters);
	
	U.signal = {};
	U.meta.bandwidth = [];
	U.meta.resolution = [];
	U.meta.scale = zeros(0,size(in.meta.scale,2)+1);
	
	rS = 1;
	rU = 1;
	for k1 = 0:length(in.signal)-1
		sig = in.signal{k1+1};
		sig_f = fft(sig,[],1);	
		
		filter_bw = phi_bw;
		ds = max(0,round(log2(2*pi/filter_bw))-log2(filters.N/size(sig,1))-options.antialiasing);
		S.signal{rS} = real(conv_sub(sig_f,filters.phi.filter,ds));
		S.meta.bandwidth(rS,1) = filter_bw;
		S.meta.resolution(rS,1) = log2(filters.N/size(S.signal{rS},1));
		S.meta.scale(rS,:) = in.meta.scale(k1+1,:);
		
		rS = rS+1;
		
		for k2 = find(in.meta.bandwidth(k1+1)>psi_xi)-1
			filter_bw = psi_bw(k2+1);
			ds = max(0,round(log2(2*pi/filter_bw/2))-log2(filters.N/size(sig,1))-options.antialiasing);
			U.signal{rU} = abs(conv_sub(sig_f,filters.psi.filter{k2+1},ds));
			U.meta.bandwidth(rU,1) = filter_bw;
			U.meta.resolution(rU,1) = log2(filters.N/size(U.signal{rU},1));
			U.meta.scale(rU,:) = [in.meta.scale(k1+1,:) k2];
			
			rU = rU+1;
		end
	end
end

function y = conv_sub(xf,filter,ds)
	if isnumeric(filter)
		N = size(filter,1);
		j0 = log2(N/size(xf,1));
		filter_per = sum(reshape(filter,[N/2^j0 2^j0]),2);
		yf = xf.*filter_per;
		yf = sum(reshape(yf,[size(yf,1)/2^ds 2^ds]),2)/2^(ds/2);
		y = ifft(yf,[],1);
	elseif isstruct(filter) && strcmp(filter.type,'fourier_multires')
		N = filter.N;
		j0 = log2(N/size(xf,1));
		yf = xf.*filter.coefft{j0+1};
		yf = sum(reshape(yf,[size(yf,1)/2^ds 2^ds]),2)/2^(ds/2);
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