% RICHARDSON_LUCY The Richardson-Lucy deconvolution algorithm
%
% Usage
%    y = richardson_lucy(z, filter, options)
%
% Input
%    z (numeric): The filtered signal to be deconvolved.
%    filter (struct): The filter used to obtain z, in the format of filters
%        from FILTER_BANK.
%    options (struct, optional): Different parameters, such as
%            rl_iter (numeric): The iterations to output. If multiple are
%                specified, they will be arranged in y as columns (default 32)
%
% Output
%     y (numeric): The result of the algorithm.
%
% Description
%    The Richardson-Lucy algorithm estimates a signal y from its convolution
%    z = y*h, where h is a filter, often lowpass. The algorithm is iterative
%    and converges to the pseudo-inverse of the convolution operator, which is
%    unstable when the Fourier transform of the filter takes values close to
%    zero. As a result, only a few iterations are used. For more details, see
%    [1] and [2].
%    
% References
%    [1] L. Lucy, “An iterative technique for the rectiﬁcation of observed 
%       distributions,” Astron. J., vol. 79, p. 745, 1974. 
%    [2] W.H. Richardson, "Bayesian-based iterative method of image 
%       restoration." JOSA vol. 62.1, p. 55-59, 1972.

function yn = richardson_lucy(z, filter, options)
	if nargin < 3
		options = struct();
	end
	
	options = fill_struct(options, 'rl_iter', 32);

	yn = zeros(length(z),length(options.rl_iter));
	
	h = realize_filter(filter, size(z,1));

	h_filter = @(u)(real(ifft(fft(u).*h)));
	ht_filter = @(u)(real(ifft(fft(u).*conj(h))));

	y = z;

	for n = 1:max(options.rl_iter)
		zr = z./(h_filter(y));

		y = y.*ht_filter(zr);

		if ismember(n, options.rl_iter)
			[temp,k] = ismember(n, options.rl_iter);
			yn(:,k) = y;
		end
	end
end
