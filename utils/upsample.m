% UPSAMPLE Upsamples a signal using cubic spline interpolation
%
% Usage
%    y = upsample(x, N)
%
% Input
%    x (numeric): The signal to be upsampled.
%    N (numeric): The number of points in the upsampled signal.
%
% Output
%    y (numeric): The upsampled signal.
%
% Description
%    The input signal x is interpolated using cubic splines through the 
%    INTERP1 function with symmetric boundary conditions.
%
% See also 
%   INTERP1

function y = upsample(x, N)
	y = interp1([-length(x):2*length(x)-1].', ...
		[flipud(x(:)); x(:); flipud(x(:))], ...
		[0:N-1].'/N*length(x), 'spline');
end