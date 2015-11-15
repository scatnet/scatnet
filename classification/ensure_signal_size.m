% ENSURE_SIGNAL_SIZE Pads or truncates a signal
%
% Usage
%    y = ENSURE_SIGNAL_SIZE(x, N);
%
% Input
%    x (numeric): A signal of size NxKxP to be padded or truncated.
%    N (int): The desired signal size, in one or two dimensions.
%
% Output
%    y (numeric): A signal of size [N(1) N(2)] in the first two dimensions.

function y = ensure_signal_size(x, N)
	N0 = size(x);

	if numel(N) == 1
		N(2) = N0(2);
	end

	if N0(1) < N(1)
		x = cat(1, x, zeros([N(1)-N0(1) N0(2:end)]));
	elseif N0(1) > N(1)
		x = x(1:N(1),:,:);
	end

	if N0(2) < N(2)
		x = cat(2, x, zeros([size(x, 1) N(2)-N0(2) N0(3:end)]));
	elseif N0(2) > N(2)
		x = x(:,1:N(2),:);
	end

	y = x;
end

