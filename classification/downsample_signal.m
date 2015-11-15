% DOWNSAMPLE_SIGNAL Downsamples a signal by a power of two
%
% Usage
%    y = DOWNSAMPLE_SIGNAL(x, ds);
%
% Input
%    x (numeric): A signal of size NxKxP to be downsampled.
%    ds (int): The downsampling in octaves, resulting in a 2^ds factor.
%
% Output
%    y (numeric): A signal of size N/2^ds in the first dimension.

function y = downsample_signal(x, ds)
	N = size(x, 1);

	x_f = fft(x, [], 1);

	y_f = [x_f(1:N/2^(ds+1),:,:);
	       x_f(N/2^(ds+1)+1,:,:)/2+x_f(N-N/2^(ds+1)+1,:,:)/2;
	       x_f(N-N/2^(ds+1)+2:N,:,:)];

	y = ifft(y_f, [], 1);
end

