function [X,ind,W] = fast_dct(x,ind,W)
	N = size(x,1);
	%K = size(x,2);
	
	if nargin < 2
		ind = [1:2:N-1 N:-2:2]';
	end
	
	if nargin < 3
		W = exp(-2*pi*i*[0:N-1]'/(4*N));
		W(1) = W(1)*sqrt(1/N);
		W(2:end) = W(2:end)*sqrt(2/N);
	end
	
	%x = reshape(x,[2 N/2]);
	%x(2,:) = x(2,N/2:-1:1);
	%x = permute(x,[2 1]);
	%v = reshape(x,[N 1]);
	
	v = x(ind,:);
	V = fft(v);
	%V = V(1:N/2+1).*W(1:N/2+1);
	%X = [real(V); -imag(flipud(V(2:N/2)))];
	
	V = bsxfun(@times,V,W);
	X = real(V);
end