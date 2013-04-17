function X = ave_scatt(X,T,step,window_fun)
	if nargin < 3
		step = T/2;
	end
	
	if nargin < 4
		window_fun = @hanning;
	end
	
	for m = length(X)-1:-1:0
		for p1 = 1:length(X{m+1}.signal)
			res = X{m+1}.meta.resolution(p1);
			N0 = size(X{m+1}.signal{p1},1);
			real_T = T/2^res;
			real_step = step/2^res;
			n_windows = floor(length(X{m+1}.signal{p1})/real_step);
			buf = zeros(real_T,n_windows,size(X{m+1}.signal{p1},2));
			ind0 = [1:N0 N0:-1:1];
			for k = 1:n_windows
				center = (k-1)*real_step+1;
				ind = ind0(mod(floor([center-real_T/2+1:center+real_T/2])-1,2*N0)+1);
				buf(:,k,:) = X{m+1}.signal{p1}(ind,:);
			end
			kernel = window_fun(size(buf,1));
			buf = bsxfun(@times,buf,kernel/sum(kernel));
			buf = sum(buf,1);
			buf = reshape(buf,[size(buf,2) size(buf,3)]);
			X{m+1}.signal{p1} = buf;
			X{m+1}.meta.resolution(p1) = res+log2(real_step);
		end
	end
end